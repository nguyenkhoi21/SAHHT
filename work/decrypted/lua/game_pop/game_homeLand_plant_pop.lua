--- 家园种植界面

local game_homeLand_plant_pop = {
    m_popUi = nil,
    m_close_btn = nil,
    m_node_tableView = nil,
    m_cfg_homeland_grow = nil,
    m_framId = nil,
    m_growData = nil,
    m_growIdTab = nil,
};
--[[--
    销毁ui
]]
function game_homeLand_plant_pop.destroy(self)
    -- body
    cclog("-----------------game_homeLand_plant_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_node_tableView = nil;
    self.m_close_btn = nil;
    self.m_cfg_homeland_grow = nil;
    self.m_framId = nil;
    self.m_growData = nil;
    self.m_growIdTab = nil;

end
--[[--
    返回
]]
function game_homeLand_plant_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_homeLand_plant_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_homeLand_plant_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        
        elseif btnTag > 100 and btnTag < 104 then
         
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_homeLand_plant_pop.ccbi");
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_layer_mask = ccbNode:layerForName("m_layer_mask")
    local function onTouch2(eventType, x, y)   
        if eventType == "began" then 
            -- self:back()            
            return true;  
        elseif eventType == "ended" then
            local realPos = m_layer_mask:getParent():convertToNodeSpace(ccp(x,y));
            if not m_layer_mask:boundingBox():containsPoint(realPos) then
                self:back()
            else
                return
            end
        end 
    end
    m_root_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-4,true);
    m_root_layer:setTouchEnabled(true);
    m_layer_mask:setVisible(false)
    -- cclog2(m_layer_mask:getContentSize(),"width ---- ")
    -- local function onTouch1(eventType, x, y) 
    --     cclog("ontouch m_layer_mask============")    
    --     if eventType == "began" then 
    --         -- self:back()            
    --         return true;  
        
    --     end 
    -- end
    -- m_layer_mask:registerScriptTouchHandler(onTouch1,false,GLOBAL_TOUCH_PRIORITY-5,true);
    -- m_layer_mask:setTouchEnabled(true);
    return ccbNode;
end
function game_homeLand_plant_pop.getCfgdata( self )
    self.m_growIdTab = {}
    self.m_growData = {}
    if tonumber(self.m_framId)  % 2 == 0  then -- 粉钻的
        self.m_growData[tostring(1)] = self.m_cfg_homeland_grow["16"]
    else -- 不是粉钻的
        local index = 1
        for i=1,game_util:getTableLen(self.m_cfg_homeland_grow) do
            if i ~= 16 then

                local start_time = self.m_cfg_homeland_grow[tostring(i)].start_time
                local close_time = self.m_cfg_homeland_grow[tostring(i)].close_time
                local serTime = game_data:getUserStatusDataByKey("server_time")
                serTime = os.date("%H:%M:%S",serTime)
                if start_time <= serTime and serTime <= close_time then
                    table.insert(self.m_growIdTab, i )
                    self.m_growData[tostring(index)] = self.m_cfg_homeland_grow[tostring(i)]
                    index = index + 1 
                end
            end
        end
    end
end
--[[--
    创建活动列表
]]
function game_homeLand_plant_pop.createTableView(self,viewSize)
    -- cclog2(self.m_growData,"zz=   == =  ")
    local function onCellClick( event,target )
        -- body
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag()
        cclog2(btnTag,"btnTag =====")
        local t_params = 
          {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                game_util:closeAlertView();
                local params = {} 
                if self.m_framId % 2 == 0 then
                    params.c_id = 16
                else
                    params.c_id = self.m_growIdTab[btnTag]
                end
                params.farm_id = self.m_framId
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_homeLand_main",{gameData = gameData});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_sowing"), http_request_method.GET, params,"homeland_sowing")
            end,   --可缺省
            closeCallBack = function(target,event)
                game_util:closeAlertView();
            end,
            okBtnText = "OK",       --可缺省
            text = "Trồng đạo cụ này?",      --可缺省
          }
          game_util:openAlertView(t_params);
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 3; --列
    params.totalItem = game_util:getTableLen(self.m_growData);
    -- cclog2(self.m_growData,"m_growData ----- ")
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            -- ccbNode:openCCBFile("ccb/ui_homeLand_plant_pop.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5 + 3));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            ccbNode:removeAllChildrenWithCleanup(true)
            local itemData = {}
            itemData = self.m_growData[tostring(index + 1)]
            -- cclog2(itemData,"itemData ==== ")
            local icon,name,count = nil,nil,nil
            if self.m_framId % 2 == 0 then --只种粉钻
                icon,name,count = CCSprite:createWithSpriteFrameName("fenzuan.png"),"Đá Fancy",0
                for i=1,game_util:getTableLen(itemData.item) do
                    count = count + itemData.item[i][3]
                end
            else
                -- cclog2(itemData.item[1],"itemData.item  ==== ")
                icon,name,count = game_util:getRewardByItemTable(itemData.item[1])
                count = 0
                for i=1,game_util:getTableLen(itemData.item) do
                    count = count + itemData.item[i][3]
                end
            end
            if icon then
                icon:setScale(0.75)
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                if icon:getChildByTag(999) then
                    icon:removeChildByTag(999)
                end
                local countlab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,10)
                countlab:setPosition(ccp(20,-8))
                icon:addChild(countlab)
                -- icon:removeAllChildrenWithCleanup(true)
                icon:addChild(button,10,999)
                button:setTag(index + 1)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
                button:setPosition(ccp(20,20))
                button:setOpacity(0)
                ccbNode:addChild(icon)
            else

            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            -- local t_params = 
              -- {
              --   title = string_config.m_title_prompt,
              --   okBtnCallBack = function(target,event)
              --       game_util:closeAlertView();
              --       local params = {} 
              --       params.farm_id = self.m_framId
              --       params.c_id = index + 1
              --       local function responseMethod(tag,gameData)
              --           game_scene:enterGameUi("game_homeLand_main",{gameData = gameData});
              --       end
              --       network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_sowing"), http_request_method.GET, params,"homeland_sowing")
              --   end,   --可缺省
              --   closeCallBack = function(target,event)
              --       game_util:closeAlertView();
              --   end,
              --   okBtnText = "确定",       --可缺省
              --   text = "是否种植该道具",      --可缺省
              -- }
              -- game_util:openAlertView(t_params);
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_homeLand_plant_pop.refreshUi(self)
    self.m_node_tableView:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_node_tableView:getContentSize());
    self.m_node_tableView:addChild(tableViewTemp);
    tableViewTemp:setScrollBarVisible(false)
  
end
--[[--
    初始化
]]
function game_homeLand_plant_pop.init(self,t_params)
    self.m_cfg_homeland_grow = json.decode(getConfig(game_config_field.homeland_grow):getFormatBuffer())
    -- cclog2(self.m_cfg_homeland_grow,"mmmcfg ----")
    if t_params.framId then
        self.m_framId = t_params.framId
    end
    self:getCfgdata()
end

--[[--
    创建ui入口并初始化数据
]]
function game_homeLand_plant_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_homeLand_plant_pop;