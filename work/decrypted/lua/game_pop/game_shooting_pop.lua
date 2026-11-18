--
-- Author: fan.xia
-- Date: 2019-03-30 15:41:15
--

--
-- Author: fan.xia
-- Date: 2019-03-27 10:16:50
--
local game_shooting_pop = {
	m_root_layer = nil,
    m_ccbNode = nil,
    m_quad_txt = nil,
    m_data = nil,
}

--[[--
    销毁
]]
function game_shooting_pop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_quad_txt = nil;
    self.m_data = nil;
end

--[[--
    返回
]]
function game_shooting_pop.back(self,type)
    --回到activity
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end

function game_shooting_pop.createUi(self)
   local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then
            
        elseif btnTag == 3 then
            function shopOpenResponseMethod(tag,gameData)
            	game_scene:enterGameUi("game_shooting",{gameData = gameData}) 
        	end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("god_shot_index"), http_request_method.GET, {},"channel_active_recharge_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_shooting_overpop.ccbi");

    self.m_ccbNode = ccbNode

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.root_node = ccbNode:nodeForName("root_node")
    self.m_yunumber_txt = ccbNode:labelTTFForName("m_yunumber_txt")
    self.m_quad_txt = ccbNode:labelTTFForName("m_quad_txt")
    self.m_yubi_txt = ccbNode:labelTTFForName("m_yubi_txt")
    local m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
    local m_start_btn = ccbNode:controlButtonForName("m_start_btn")
    m_start_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)

    local function onTouch(eventType, x, y)
        if eventType == "began" then

            return true;--intercept event
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode
end

function game_shooting_pop.createAnimian(self)
    local animFile = "shenshe_zidan"
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
     
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("zidanjiemian");
    m_iAnim:setScale(1);
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    m_iAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
   
    self.root_node:addChild(m_iAnim,10,10)
end

function game_shooting_pop.refreshUi(self)
    self.m_yunumber_txt:setString("Số lần còn："..self.m_data.remain_num) --剩余次数
    self.m_quad_txt:setString(self.m_data.last_scores)
    self.m_yubi_txt:setString("Xu VT："..self.m_data.reward.universe_coin) --宇宙币
end

function game_shooting_pop.init(self,t_params)
   self.m_data = t_params.data
   cclog2(self.m_data,"m_data")
end

--[[--
    创建ui入口并初始化数据
]]--
function game_shooting_pop.create(self,t_params)
   cclog("----- game_shooting_pop create --------")
    self:init(t_params);
    local popui = self:createUi();
    self:refreshUi()
  
    return popui
end

return game_shooting_pop