---  消息
local game_notify_message_scene = {
    m_tGameData     = nil,
    m_tGameData2    = nil,
    m_root_layer    = nil,
    
    m_tab_btn_1     = nil, 
    m_tab_btn_2     = nil, 
    m_btn_getall    = nil,     
    
    m_node_list     = nil, 
    m_lb_page       = nil, 
    m_sp_left       = nil, 
    m_sp_right      = nil, 
    m_tab           = nil,
    m_curPage       = nil,
    m_lb_yijian_des = nil,

    showDataTable = {},


};


--[[--
    销毁
]]
function game_notify_message_scene.destroy(self)
    -- body
    cclog("-----------------game_notify_message_scene destroy-----------------");
    self.m_tGameData    = nil;
    self.m_tGameData2   = nil;
    self.m_root_layer   = nil;

    self.m_tab_btn_1    = nil;
    self.m_tab_btn_2    = nil;
    self.m_btn_getall   = nil;   

    self.m_node_list    = nil;
    self.m_lb_page      = nil;
    self.m_sp_left      = nil;
    self.m_sp_right     = nil;
    self.m_tab          = nil;
    self.m_curPage      = nil;
    self.m_lb_yijian_des= nil;

    self.showDataTable  = nil;


end
--[[--
    返回
]]
function game_notify_message_scene.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_notify_message_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then -- 普通消息
            self.m_curPage =1
            self.m_tab = 1
            self:refreshUi();
        elseif btnTag == 3 then -- 组队消息
            if not game_data:isViewOpenByID(213) then
                game_util:addMoveTips({text = "组队BOSS暂未开启，敬请期待！"})
                return
            end
            function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData2 = json.decode(data:getFormatBuffer()) or {}
                self.m_curPage =1
                self.m_tab = 2
                self:refreshUi();
            end
            local params = {};
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_fight_messages"), http_request_method.GET, params,"team_fight_team_fight_messages")
        elseif btnTag == 4 then -- 一键领取
            -- #self.showDataTable
            local firstItem = (self.m_curPage - 1)*6 + 1
            local endItem   = self.m_curPage * 6
            local str       = ""
            for i=firstItem, endItem do
                if self.showDataTable[i] then
                    if i%6 == 1 then
                        str = str .. self.showDataTable[i].id
                    else
                        str = str .."|".. self.showDataTable[i].id
                    end
                end
            end

            function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                game_util:rewardTipsByDataTable(self.m_tGameData.reward);
                self:refreshUi();
            end

            local params = {};
            params.message_id = str
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("notify_messages_auto_read"), http_request_method.GET, params,"notify_messages_auto_read")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_notify_message2.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_tab_btn_1     = ccbNode:controlButtonForName("m_tab_btn_1")
    self.m_tab_btn_2     = ccbNode:controlButtonForName("m_tab_btn_2")
    self.m_btn_getall    = ccbNode:controlButtonForName("m_btn_getall")
    
    self.m_node_list     = ccbNode:nodeForName("m_node_list")
    self.m_lb_page       = ccbNode:labelTTFForName("m_lb_page")
    self.m_lb_yijian_des = ccbNode:labelTTFForName("m_lb_yijian_des")
    self.m_sp_left       = ccbNode:spriteForName("m_sp_left")
    self.m_sp_right      = ccbNode:spriteForName("m_sp_right")

    return ccbNode;
end

function game_notify_message_scene.setcellInfo(self,ccbNode,data,index)
    local function onClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal(data.gift[btnTag])
    end
    local m_ItemBG      = ccbNode:spriteForName("m_ItemBG")
    local m_sp_look     = ccbNode:spriteForName("m_sp_look")
    local m_lb_detail   = ccbNode:labelTTFForName("m_lb_detail")
    local m_node_icon   = ccbNode:nodeForName("m_node_icon")
    local m_node_reward = ccbNode:nodeForName("m_node_reward")
    local m_btn_look    = ccbNode:controlButtonForName("m_btn_look")
    m_btn_look:setTag(index)
    m_node_reward:removeAllChildrenWithCleanup(true)
    if self.m_tab == 1 then
        local contentTab = util.stringSplit(data.content,"\n")
        local content = contentTab[1]
        -- local content = data.content
        if game_util:utfstrlen(content)>50 then
            content = game_util:subUTF8String(content,50)
        end
        m_lb_detail:setString(content)

        if next(data.gift) then
            local icon1,name1,count1 = game_util:getRewardByItemTable(data.gift[1])
            local offsetXetc = icon1:getContentSize().width *1.9
            if #data.gift >3 then
                for i=1,3 do
                    if i == 3 then
                        local etc = CCLabelTTF:create("...",TYPE_FACE_TABLE.Arial_BoldMT,14)
                        m_node_reward:addChild(etc)
                        etc:setPosition(ccp(offsetXetc,2))
                        etc:setColor(ccc3(230,160,0))
                    else
                        local icon,name,count = game_util:getRewardByItemTable(data.gift[i])
                        if icon then
                            m_node_reward:addChild(icon)
                            icon:setAnchorPoint(ccp(0.5,0.5))
                            icon:setScale(0.6)
                            icon:setPosition(ccp((i-1)*icon:getContentSize().width*0.7 + icon:getContentSize().width*0.5,-1))
                        end

                        local button = game_util:createCCControlButton("public_weapon.png","",onClick)
                        m_node_reward:addChild(button)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setScale(0.6)
                        button:setPosition(ccp((i-1)*icon:getContentSize().width*0.7 + icon:getContentSize().width*0.5,-1))
                        button:setTag(i)
                        button:setOpacity(0)
                    end
                end
            else
                for i=1,#data.gift do
                    local icon,name,count = game_util:getRewardByItemTable(data.gift[i])
                    if icon then
                        m_node_reward:addChild(icon)
                        icon:setAnchorPoint(ccp(0.5,0.5))
                        icon:setScale(0.6)
                        icon:setPosition(ccp((i-1)*icon:getContentSize().width*0.7 + icon:getContentSize().width*0.5,-1))
                    end

                    local button = game_util:createCCControlButton("public_weapon.png","",onClick)
                    m_node_reward:addChild(button)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setScale(0.6)
                    button:setPosition(ccp((i-1)*icon:getContentSize().width*0.7 + icon:getContentSize().width*0.5,-1))
                    button:setTag(i)
                    button:setOpacity(0)
                end
            end
        end
    else
        m_lb_detail:setString(data.title)
    end
end

function game_notify_message_scene.receiveAwards(self,index)
    local tGameData = self.m_tGameData.messages or {};
    local itemData = tGameData[index]
    function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
        game_util:rewardTipsByDataTable(self.m_tGameData.reward);
        self:refreshUi();
    end
    local params = {};
    params.message_id = itemData.id;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("notify_read"), http_request_method.GET, params,"notify_read")
end

function game_notify_message_scene.createMessageTableView(self,viewSize,tabid)
    self.showDataTable = tabid == 1 and self.m_tGameData.messages or self.m_tGameData2.messages
    self.showDataTable = self.showDataTable or {}
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

        if self.m_tab == 1 then
            local t_params = {}
            t_params.messages = self.showDataTable[btnTag]
            t_params.okBtnCallBack = function()
                game_scene:removePopByName("game_message_pop")
                self:receiveAwards(btnTag);
            end
            game_scene:addPop("game_message_pop",t_params)
        else 
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_scene:enterGameUi("game_TeamTask_main",
                    {gameData = data,
                    fromtype = "notify",
                    boss_index = self.showDataTable[btnTag].boss_index,
                    boss_lv = self.showDataTable[btnTag].boss_level,
                    boss_id =self.showDataTable[btnTag].boss_id, 
                    boss_type =self.showDataTable[btnTag].boss_type ,
                    team_id = self.showDataTable[btnTag].team_id,
                    msg_id = self.showDataTable[btnTag].id,
                    })
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_index"), http_request_method.GET, nil,"team_fight_index")
        end
    end

    local totalItem = #self.showDataTable
    local params = {};
    params.viewSize = viewSize;
    params.row = 6;--行
    params.column = 1; --列
    params.totalItem = #self.showDataTable;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1;
    params.showPageIndex = self.m_curPage or 1
    params.itemActionFlag = true;
    params.showPoint = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_notify_message_item2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            self:setcellInfo(ccbNode,self.showDataTable[index+1],index+1)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage or 1
        if self.m_tab==1 then
            self.m_lb_page:setString(self.m_curPage.."  /  "..math.floor((#self.m_tGameData.messages+5)/6))
        elseif self.m_tab==2 then
            self.m_lb_page:setString(self.m_curPage.."  /  "..math.floor((#self.m_tGameData2.messages+5)/6) )
        else
            self.m_lb_page:setString("")
        end

        if #self.showDataTable == 0 then
            self.m_lb_page:setString("0  /  0")
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_notify_message_scene.refreshUi(self)
    self.m_tab_btn_1:setEnabled(self.m_tab ~= 1)
    self.m_tab_btn_2:setEnabled(self.m_tab ~= 2)
    self.m_btn_getall:setVisible(self.m_tab == 1)
    self.m_lb_yijian_des:setVisible(self.m_tab == 1)
    self.m_node_list:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createMessageTableView(self.m_node_list:getContentSize(),self.m_tab)
    self.m_node_list:addChild(tempTableView)
    self.m_curPage = self.m_curPage or 1
    if self.m_tab==1 then
        self.m_lb_page:setString(self.m_curPage.."  /  "..math.floor((#self.m_tGameData.messages+5)/6))
    elseif self.m_tab==2 then
        self.m_lb_page:setString(self.m_curPage.."  /  "..math.floor((#self.m_tGameData2.messages+5)/6))
    else
        self.m_lb_page:setString("")
    end
    if #self.showDataTable == 0 then
        self.m_lb_page:setString("0  /  0")
    end
end

--[[--
    初始化
]]
function game_notify_message_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_tGameData = {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
    end

    self.m_tab = self.m_tab or 1

    if t_params.opentype then
        function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            self.m_tGameData2 = json.decode(data:getFormatBuffer()) or {}
            self.m_tab = 2
            self:refreshUi();
        end
        local params = {};
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_fight_messages"), http_request_method.GET, params,"team_fight_team_fight_messages")
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_notify_message_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi())
    self:refreshUi();
    return scene;
end

return game_notify_message_scene;
