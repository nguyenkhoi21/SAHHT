--- 工会战对阵列表

local game_server_guildbattle_list = {
   m_node_list=nil,
   m_tGameData=nil,
   m_second=nil,
   m_btn_second=nil,
};
--[[--
    销毁
]]
function game_server_guildbattle_list.destroy(self)
    -- body
    cclog("-----------------game_server_guildbattle_list destroy-----------------");
    self.m_node_list=nil;
    self.m_tGameData=nil;
    self.m_second=nil;
    self.m_btn_second=nil;
end
--[[--
    返回
]]
function game_server_guildbattle_list.back(self,type)
    game_scene:removePopByName("game_server_guildbattle_list");
end
--[[--
    读取ccbi创建ui
]]
function game_server_guildbattle_list.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag==2 then
            local function responseMethod(tag,gameData)

                if not self.m_second then
                    self.m_second=true;
                else
                    self.m_second=false;
                end

                local data=gameData:getNodeWithKey("data")
                data = data:getNodeWithKey("rank") or {}
                self.m_tGameData=json.decode( data:getFormatBuffer() )  or {}
                self:refreshUi()
            end
            local params={};
            if not self.m_second then

                --self.m_second=true;
               
                params.num=2;
            else
                --self.m_second=false;
             
                params.num=1;
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_convention_overview"), http_request_method.GET,params,"new_guild_fight_convention_overview")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_guild_battle_detail.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")

    local m_close_btn = ccbNode:controlButtonForName("btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    self.m_btn_second=ccbNode:controlButtonForName("btn_second")
    self.m_btn_second:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.m_node_list=ccbNode:nodeForName("node_list")


    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
   
    return ccbNode;
end

--[[
    创建列表
]]
function game_server_guildbattle_list.createTabelView(self,viewSize)
    
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #self.m_tGameData.info

    params.touchPriority = GLOBAL_TOUCH_PRIORITY-15;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_guild_battle_detail_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5-5,itemSize.height*0.5+10));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local label_server1=ccbNode:labelTTFForName("label_server1");
            local label_server2=ccbNode:labelTTFForName("label_server2");
            local label_guild1=ccbNode:labelTTFForName("label_guild1");
            local label_guild2=ccbNode:labelTTFForName("label_guild2");
            local data=self.m_tGameData.info[index+1]
            if data then 
                label_server1:setString(data[1][1])
                label_server2:setString(data[2][1])
                label_guild1:setString(data[1][2])
                label_guild2:setString(data[2][2])
            else
                label_server1:setString("暂无")
                label_server2:setString("暂无")
                label_guild1:setString("暂无")
                label_guild2:setString("暂无")
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
          
        end
    end
    return TableViewHelper:create(params);
end




--[[
    刷新
]]
function game_server_guildbattle_list.refreshTableView(self)
   self.m_node_list:removeAllChildrenWithCleanup(true)
   local tempRewardTable = self:createTabelView(self.m_node_list:getContentSize());
   self.m_node_list:addChild(tempRewardTable,10,10)
end

--[[--
    刷新ui
]]
function game_server_guildbattle_list.refreshUi(self)
    self:refreshTableView()
    if self.m_second then
        game_util:setCCControlButtonTitle(self.m_btn_second,"查看第一场")
    else
        game_util:setCCControlButtonTitle(self.m_btn_second,"查看第二场")
    end
   
end

--[[--
    初始化
]]
function game_server_guildbattle_list.init(self,t_params)
    t_params = t_params or {};
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_serverGuild.plist");
    local data = t_params.gameData:getNodeWithKey("rank") or {}
    self.m_tGameData=json.decode( data:getFormatBuffer() )  or {}
    self.m_second=false;
   
end

--[[--
    创建ui入口并初始化数据
]]
function game_server_guildbattle_list.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi()
    return scene;
end

return game_server_guildbattle_list;