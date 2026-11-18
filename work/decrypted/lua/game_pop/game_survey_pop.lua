--问卷调查
local game_survey_pop = {
	m_showTime_lab = nil,
	m_root_layer = nil,
	m_btn_go = nil,
	m_close_layer = nil,
	m_reward_node = nil,

}
function game_survey_pop.destroy( self )
	self.m_showTime_lab = nil;
	self.m_root_layer = nil;
	self.m_btn_go = nil;
	self.m_close_layer = nil;
	self.m_reward_node = nil;
	
	cclog("--------game_survey_pop.destory-------")
end
function game_survey_pop.back( self )
	 local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
function game_survey_pop.createUi( self )
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local ccbNode = tolua.cast(target,"CCNode")
		local btnTag = ccbNode:getTag()
		if btnTag == 2 then 
			util_system:openUrlOutside(self.m_openUrl);
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_survey_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName('m_root_layer')
	self.m_btn_go = ccbNode:controlButtonForName("m_btn_go")
	self.m_reward_node = ccbNode:nodeForName("m_reward_node")
	self.m_showTime_lab =  ccbNode:labelTTFForName("m_showTime_lab")
	self.m_showTime_lab2 =  ccbNode:labelTTFForName("m_showTime_lab2")

	self.m_btn_go:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

	local function onTouch(eventType, x, y)
	    if eventType == "began" then
	        return true;
	    elseif eventType == "ended" then
	    end
	end
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true)
	self.m_root_layer:setTouchEnabled(true);

	local m_close_layer = ccbNode:layerForName("m_close_layer")
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            local realPos = m_close_layer:getParent():convertToNodeSpace(ccp(x,y));
            if not m_close_layer:boundingBox():containsPoint(realPos) then
            	self:back()
            else
            	return
            end
        elseif eventType == "ended" then
        end
    end
    m_close_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-4,true);
    m_close_layer:setTouchEnabled(true);
	return ccbNode
	-- body
end


function game_survey_pop:createReward(rewardTab)
	self.m_reward_node:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_reward_node:getContentSize()
	local itemSize = viewSize.width/(#rewardTab)

    function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        game_util:lookItemDetal( rewardTab[btnTag] )
    end

	for i=1,#rewardTab do
		local rewardItem = rewardTab[i]
		if rewardItem then
	        local icon,name,count = game_util:getRewardByItemTable(rewardItem);
            if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition( itemSize/2*(2*i-1), viewSize.height * 0.6 )
                icon:setScale(0.8)
                self.m_reward_node:addChild(icon, -1, 20)

                if name and count then
                    local labelName = game_util:createLabelBMFont({text = "x" .. count, fontSize = 20, color = ccc3(255, 255, 255)})
                    labelName:setAnchorPoint(ccp(1, 0))
                    labelName:setPosition(icon:getContentSize().width-2,  2 )
                    icon:addChild(labelName, 10)
                end

                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                icon:addChild(button)
                button:setTag(i)
            end
        end
	end
end


function game_survey_pop.refreshUi( self )
	local m_config = getConfig(game_config_field.survey)
	m_config = json.decode(m_config:getNodeWithKey("1"):getFormatBuffer())
 	self.m_showTime_lab:setString(m_config.show_time)
 	self.m_showTime_lab2:setString(m_config.show_time)
 	self.m_openUrl = m_config.active_url or "https://goo.gl/DvKP1J"
 	self:createReward(m_config.reward or {{9,0,200},{6,522034,1},{5,53,5}})
end

function game_survey_pop.init( self,t_params )

			
end
function game_survey_pop.create( self,t_params )
	self:init(t_params)
	self.m_Pop = self:createUi()
	self:refreshUi()
	return self.m_Pop
	-- body
end
return game_survey_pop;