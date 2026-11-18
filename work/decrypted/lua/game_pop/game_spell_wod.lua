---  拼图规则

local game_spell_wod = {
    m_popUi = nil,
    m_version = nil,
};
--[[--
    销毁ui
]]
function game_spell_wod.destroy(self)
    -- body
   self.m_version = nil;
    self.m_popUi = nil;
end
--[[--
    返回
]]
function game_spell_wod.back(self,backType)
   
    game_scene:removePopByName("game_spell_wod");
end
--[[--
    读取ccbi创建ui
]]
function game_spell_wod.createUi(self)
    local editText = "";
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_spell_wod.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);

    self.m_list_node = ccbNode:nodeForName("m_list_node")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end

    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-13,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_spell_wod.createTableView(self, viewSize)
    local jigsaw_cig = getConfig( game_config_field.jigsaw )
    local jigsawTab = json.decode(jigsaw_cig:getFormatBuffer())
    local icon = jigsawTab[tostring(self.m_version)]["jigsaw_icon1"][1]
    local cardsCount = 9
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 3; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-13
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = CCSprite:createWithSpriteFrameName(icon.."_js_1.png")  
            ccbNode:setScale(0.8)
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            local shdf = CCSprite:createWithSpriteFrameName("sy.png")
            local size = ccbNode:getContentSize()
            shdf:setPosition(ccp(size.width*0.5,size.height*0.5))
            ccbNode:addChild(shdf,12,12)
            local label = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,12)
            label:setPosition(ccp(65,0))
            ccbNode:addChild(label,11,11)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(ccbNode,10,10)
        end
        if cell and index < cardsCount then
            local ccbNode = cell:getChildByTag("10")
            local label = ccbNode:getChildByTag("11")
            local shdf = ccbNode:getChildByTag("12")
            if ccbNode then
                local dex = index + 1
                local fileName = icon.."_js_"..dex..".png"
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName))
                if tempSpriteFrame then
                    local sp = tolua.cast(ccbNode,"CCSprite") 
                    sp:setDisplayFrame(tempSpriteFrame)
                end

                if dex == 2 or dex == 3 or dex == 5 or dex == 6 or dex == 8 or dex == 9 then
                    label:setPosition(ccp(80,0))
                    local size = ccbNode:getContentSize()
                    shdf:setPosition(ccp(size.width*0.5+10,size.height*0.5-5))
                end
                local count = self.m_data[tostring(dex)]
                local tempTxt = tolua.cast(label,"CCLabelTTF")
                tempTxt:setString("X"..count)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" then
            local item_id = index + 1
            local params = {}
            params.pos = item_id
            function shopOpenResponseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                self.m_data = data.my_jigsaw_index
                game_util:addMoveTips({text = "Hoàn tất sử dụng tranh ghép"})
                if self.m_callback then
                    self.m_callback(data.index)
                end
                self:refreshUi()
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("jigsaw_my_use_jigsaw"), http_request_method.GET, params, "jigsaw_my_use_jigsaw")  
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
       -- self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

--[[--
    刷新ui
]]
function game_spell_wod.refreshUi(self)
    self.m_tableView2 = nil
    self.m_list_node:removeAllChildrenWithCleanup(true)
    self.m_tableView2 = self:createTableView(self.m_list_node:getContentSize())
    self.m_list_node:addChild(self.m_tableView2)
end
--[[--
    初始化
]]
function game_spell_wod.init(self,t_params)
    local data = t_params.gameData or {};
    self.m_callback = t_params.callBack
    self.m_version = t_params.version

  
    self.m_data = json.decode(data:getFormatBuffer()).data

    cclog2(self.m_data,"self.m_data")
end

--[[--
    创建ui入口并初始化数据
]]
function game_spell_wod.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_spell_wod;