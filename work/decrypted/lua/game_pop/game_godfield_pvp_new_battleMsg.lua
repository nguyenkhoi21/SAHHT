--星域竞技场   战报
local game_godfield_pvp_new_battleMsg = {
	m_root_layer = nil,
	m_btn_back = nil,
	callback = nil,

    ccbNode = nil,
    m_list_node = nil,
    m_sheng_number = nil,
    m_bai_number = nil,
    m_shenglv = nil,
    m_lianshengMax = nil,
    m_lianbaiMax = nil,
    m_my_score = nil,
    m_my_rank = nil,
    m_selectd_index = nil,
    m_tGameData = nil,
    m_enterType = nil,
    indexDic = {},
    m_pd =nil,
    flag = true,
    m_click =nil,
    m_sel_m_btn= nil,
    m_team_id = 1,
    m_result =   nil,
} 

function game_godfield_pvp_new_battleMsg:destroy( )
	self.m_root_layer = nil;
	self.m_btn_back = nil;
	self.callback = nil;

    self.ccbNode = nil;
    self.m_list_node = nil;
    self.m_sheng_number = nil;
    self.m_bai_number = nil;
    self.m_shenglv = nil;
    self.m_lianshengMax = nil;
    self.m_lianbaiMax = nil;
    self.m_my_score = nil;
    self.m_my_rank = nil;
    self.m_selectd_index = nil;
    self.m_tGameData = nil;
    self.m_enterType = nil;
    self.indexDic = {};
    self.m_pd =nil;
    self.flag = true;
    self.m_click= nil  ;
    self.m_sel_m_btn = nil;
    self.m_team_id = 1;
    self.m_result = nil;
end



function game_godfield_pvp_new_battleMsg:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("game_godfield_pvp_new_battleMsg")
end



function game_godfield_pvp_new_battleMsg:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
        self.m_team_id = btnTag
        local function responseMethod( tag,gameData )
            self.m_enterType = btnTag
            local data = gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
            self.m_sel_m_btn = nil
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_get_battle_tips"), http_request_method.GET, {team_id = btnTag},"universe_arena_get_battle_tips")
	end
	local ccbNode =  luaCCBNode:create();
	self.ccbNode = ccbNode
	ccbNode:registerFunctionWithFuncName("onMainClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_rank.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_list_node = ccbNode:nodeForName("m_list_node")
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);
    for i=1,3 do
        self.ccbNode:controlButtonForName("m_select_btn" .. i):setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    	self.ccbNode:controlButtonForName("m_select_btn" .. i):setOpacity(0)
    end
    self.m_sheng_number = ccbNode:labelTTFForName("m_sheng_number")
    self.m_bai_number = ccbNode:labelTTFForName("m_bai_number")
    self.m_shenglv = ccbNode:labelTTFForName("m_shenglv")
    self.m_lianshengMax = ccbNode:labelTTFForName("m_lianshengMax")
    self.m_lianbaiMax = ccbNode:labelTTFForName("m_lianbaiMax")
    self.m_my_score = ccbNode:labelTTFForName("m_my_score")
    self.m_my_rank = ccbNode:labelTTFForName("m_my_rank")

    self.flag =true 
    local m_back_layer = ccbNode:layerForName("m_back_layer")
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            local realPos = m_back_layer:getParent():convertToNodeSpace(ccp(x,y));
            if not m_back_layer:boundingBox():containsPoint(realPos) then
            	self:back()
            else
            	return
            end
        elseif eventType == "ended" then
        end
    end
    m_back_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-4,true);
    m_back_layer:setTouchEnabled(true);
	return ccbNode
end

function game_godfield_pvp_new_battleMsg:createTableView(viewSize)
    
    local showData = self.m_tGameData.battle_tips
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #showData--totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            local function onBtnClick( target,event )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                -- cclog("blablablablabalbalab")
                local number = btnTag -100
                --  cclog2(self.m_team_id,"team_id-=------------")
                -- cclog2(number,"num-=-------------")
            local function responseMethod(tag,gameData)
                game_data:setBattleType("game_godfield_pvp_new_battleMsg");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_get_battle_logs"), http_request_method.GET, {num = number,team_id=self.m_enterType },"universe_arena_get_battle_logs")
               
            end
            ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick)
			ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_rankItem.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);


            -- if  self.m_click and self.flag then
            --     if  index >= self.m_click   then 
            --         ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-20));   
            --     end
            -- end
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = showData[index+1]
            local m_name1 = ccbNode:labelTTFForName("m_name1")
            local m_name2 = ccbNode:labelTTFForName("m_name2")
            local m_score = ccbNode:labelTTFForName("m_score")
            local m_huizhang_count = ccbNode:labelTTFForName("m_huizhang_count")
            local m_icon_huizhang = ccbNode:spriteForName("m_icon_huizhang")
            local m_sp_result = ccbNode:spriteForName("m_sp_result")
            local m_btn_huifang = ccbNode:controlButtonForName("m_btn_huifang")
            -- ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick)
            m_btn_huifang:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
            m_btn_huifang:setTag(index+101)
            m_btn_huifang:setVisible(false)
            m_name1:setString(itemData[1] .. " VS")
            m_name2:setString(itemData[2])
            m_score:setString(itemData[3])
            m_huizhang_count:setString(itemData[4])
            m_sp_result:setVisible(true)
            
            local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_shop_icon" .. self.m_enterType .. ".png"))
            if tempSpriteFrame1 then
                m_icon_huizhang:setDisplayFrame(tempSpriteFrame1)
            end
            local r_file = itemData[5] == true and "pvp_jilu_sheng.png" or "pvp_jilu_bai.png"
            local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(r_file))
            if tempSpriteFrame2 then
                m_sp_result:setDisplayFrame(tempSpriteFrame2)
            end
        
           
            -- if self.m_click == index+1 then 
            --     m_btn_huifang:setVisible(self.flag) 
            -- end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" then

            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_sp_result = ccbNode:spriteForName("m_sp_result")

            local m_btn_huifang = ccbNode:controlButtonForName("m_btn_huifang")
            -- cclog2(self.m_click,"self.m_click-=-------")
            -- cclog2(index+1,"index+1=-=----------")
                if self.m_sel_m_btn ~=nil  then 
                    self.m_sel_m_btn:setVisible(false)
                    self.m_result:setVisible(true)
                    if self.m_click ==index +1 then 
                        self.flag =not self.flag
                        m_btn_huifang:setVisible(self.flag)
                        m_sp_result:setVisible(not self.flag)
                    else
                        m_sp_result:setVisible(false)
                        m_btn_huifang:setVisible(true)
                    end
                    -- self.m_sel_m_btn = m_btn_huifang
                else
                    m_btn_huifang:setVisible(true)
                    m_sp_result:setVisible(false)
                    -- self.m_sel_m_btn:setVisible(true)                
                end
                self.m_click =index+1
                self.m_sel_m_btn = m_btn_huifang
                self.m_result =m_sp_result
            -- if  self.m_click ==index+1  then 
            --     self.flag = not self.flag
            -- else
            --     self.flag = true
            -- end
            -- self.m_click = index+1
            -- self:refreshTableView()
        end
    end
    return TableViewHelper:create(params);
end

function game_godfield_pvp_new_battleMsg:refreshTableView()
	self.m_list_node:removeAllChildrenWithCleanup(true)
	local tempList = self:createTableView(self.m_list_node:getContentSize())
	if tempList then
		self.m_list_node:addChild(tempList)
	end
end

function game_godfield_pvp_new_battleMsg:refreshBtn(index)
	self.m_selectd_index = index
	local filesName = {"pvp_shop_pier","pvp_shop_wuerlun","pvp_shop_hatuomo"}
	for i=1,3 do
		local tempSp = self.ccbNode:spriteForName("m_select_sp" .. i)
		local fileName = filesName[i]
		local m_select_btn = self.ccbNode:controlButtonForName("m_select_btn" .. i)
		if i == index then
			fileName = fileName .. "2"
			m_select_btn:setTouchEnabled(false)
		else
			fileName = fileName .. "1"
			m_select_btn:setTouchEnabled(true)
		end
		local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName .. ".png"))
	  	if tempSpriteFrame then
	     	tempSp:setDisplayFrame(tempSpriteFrame)
	  	end
	end
end



function game_godfield_pvp_new_battleMsg:refreshUi()
    -- if self.m_pd ==nil   then
	   self:refreshBtn(self.m_enterType)
       self.flag= false
    -- end
	self:refreshTableView()
    self.m_sheng_number:setString(self.m_tGameData.vin_times)
    self.m_bai_number:setString(self.m_tGameData.fail_times)
    local value = (self.m_tGameData.vin_times+self.m_tGameData.fail_times > 0)and math.floor((self.m_tGameData.vin_times/(self.m_tGameData.vin_times+self.m_tGameData.fail_times))*100) or 0
    self.m_shenglv:setString(value .. "%")
    self.m_lianshengMax:setString(self.m_tGameData.max_vin_times)
    self.m_lianbaiMax:setString(self.m_tGameData.max_fail_times)
    self.m_my_score:setString(self.m_tGameData.score)
    self.m_my_rank:setString(self.m_tGameData.rank)
end


function game_godfield_pvp_new_battleMsg:init(t_params)

	t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
-- cclog2(self.m_tGameData,"self.m_tGameData-=-------")
    self.m_enterType = t_params.enterType or 1
end



function game_godfield_pvp_new_battleMsg:create(t_params)
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end


return game_godfield_pvp_new_battleMsg
