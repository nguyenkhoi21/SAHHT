--一元夺宝转盘
local game_indianaPan_pop={
	m_tGameData = nil, --传入的数据
	m_indianaPan_plot=nil,--配置
	m_root_layer=nil, --ccbi
	m_startAnim_node=nil,--ccbi，无实际意义，只做callfun用
	m_forone_btn=nil, --单抽ccbi
	m_refresh_btn=nil, --刷新ccbi
	m_forten_btn=nil, --十连ccbi
	m_scale9sprite_select=nil, --闪亮的格子
	m_icon_sp_tab=nil, --22个奖品格子
	m_blink_node_tab=nil, --跑马灯
	m_reward_index=nil, --单抽中奖格子号
	m_rewards_index_ten=nil,--10抽中奖格子号
	m_count_lab_tab=nil, --奖品数量
	m_out_rewardTable=nil, --外圈奖励
	m_inner_rewardTable=nil, --内圈奖励
	m_flag=nil, --单抽或者10抽标示
	m_gachaAnimEndFlag=nil,  --中奖动画标志
	m_rewards_node=nil, --十连弹出奖励框node
	m_shared=nil, --tick用
	m_pos_sp=nil, --闪亮格子位置node
	reward=nil, --单圈奖品
	m_rule_btn=nil,
	rewardfroten_tab=nil,
	m_score_lab=nil,
	m_forone_lab=nil,
	m_forten_lab=nil,
	m_refresh_lab=nil,



	
};

--销毁ui
function game_indianaPan_pop.destroy(self)
	cclog("------------game_indianaPan_pop destroy-----------")
	self.m_tGameData = nil;
	self.m_indianaPan_plot=nil;
	self.m_root_layer=nil;
	self.m_startAnim_node=nil;
	self.m_forone_btn=nil;
	self.m_refresh_btn=nil;
	self.m_forten_btn=nil;
	self.m_scale9sprite_select=nil;
	self.m_icon_sp_tab=nil;
	self.m_blink_node_tab=nil;
	self.m_reward_index=nil;
	self.m_rewards_index_ten=nil;
	self.m_count_lab_tab=nil;
	self.m_out_rewardTable=nil;
	self.m_inner_rewardTable=nil;
	self.m_flag=nil;
	self.m_gachaAnimEndFlag=nil;
	self.m_rewards_node=nil;
	self.m_shared=nil;
	self.m_pos_sp=nil;
	self.reward=nil;
	self.m_rule_btn=nil;
	self.rewardfroten_tab=nil;
	self.m_score_lab=nil;
	self.m_forone_lab=nil;
	self.m_forten_lab=nil;
	self.m_refresh_lab=nil;
	

end


--返回
function game_indianaPan_pop.back(self)
	game_scene:removePopByName("game_indianaPan_pop");
end

--createUi
function game_indianaPan_pop.createUi(self)
	local ccbNode=luaCCBNode:create();
	local function onMainBtnClick(target,event)
		local tagNode=tolua.cast(target,"CCNode");
		local btnTag=tagNode:getTag();
		
		if btnTag ==1 then  --退出
			--停止跑马灯的注册事件
			if self.m_shared~=0 then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
			end
			self:back();
		
		elseif btnTag==10 then--1次
			--停止跑马灯的注册事件
			if self.m_shared~=0 then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
			end
			local function responseMethod(tag,gameData)
				if gameData and tolua.type(gameData)=="util_json" then 
					local data=gameData:getNodeWithKey("data");
					--cclog2(data,"data is ====")
					data=json.decode(data:getFormatBuffer());
					local indexForOne=data.reward_index; --中奖格子，从0开始；
					--cclog2(indexForOne,"indexForOne===")
					self.m_reward_index=indexForOne+1; --传来的index从0开始
					self.reward=data.reward;
					self.type=data.type; 
					self.m_tGameData=data;
					self.m_flag=false; --1次标志
					self:roundone();
				end
			end
			local params={};
			params.type=1 --固定传入1
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("open_raiders_roulette"), http_request_method.GET, params,"open_raiders_roulette",true,true);
		
		elseif btnTag==20 then --shuaxin
			if self.m_shared~=0 then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
			end
			local function responseMethod(tag,gameData)
				if gameData and tolua.type(gameData)=="util_json" then
					local data=gameData:getNodeWithKey("data");
					data=json.decode(data:getFormatBuffer());
					self.m_tGameData=data;
					self:refreshUi2();	
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("refresh_raiders_roulette"), http_request_method.GET, nil,"refresh_raiders_roulette",true,true)

		elseif btnTag==30 then --10抽
			if self.m_shared~=0 then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
			end
			local function responseMethod(tag,gameData)
				if gameData and tolua.type(gameData)=="util_json" then 
					local data=gameData:getNodeWithKey("data");
					data=json.decode(data:getFormatBuffer());
					self.m_flag=true; --10次标志
					self.m_tGameData=data;
					self.rewardfroten_tab=data.gifts;
					self.m_reward_index=data.reward_indexs[1]+1;--亮框停止处
					cclog2(data.reward_indexs,"indexss");
					self:roundone();
				end
			end
			local params={};
			params.type=1 --固定传入1
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("open_raiders_roulette_10"), http_request_method.GET, params,"open_raiders_roulette_10",true,true)
			
		elseif btnTag==40  then  --说明
		 	local raiders = getConfig(game_config_field.raiders);   --配置
            local version = self.m_tGameData.version
            local des = raiders:getNodeWithKey(tostring(version)):getNodeWithKey("des"):toStr()
			game_scene:addPop("game_active_limit_detail_pop",{openMsg = des});
		end
	end

	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_indianaPan.ccbi");
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_mask_layer=ccbNode:layerForName("m_mask_layer");
	self.m_mask_layer:setVisible(false);
	self.m_mask_layer:setTouchEnabled(false);
	self.m_startAnim_node = ccbNode:nodeForName("m_anim_node");
	self.m_rewards_node=ccbNode:nodeForName("m_rewards_node");
	self.m_score_lab = ccbNode:labelTTFForName("m_score_lab");
	self.m_forone_lab = ccbNode:labelTTFForName("m_forone_lab");
	self.m_forten_lab = ccbNode:labelTTFForName("m_forten_lab");
	self.m_refresh_lab	=	ccbNode:labelTTFForName("m_refresh_lab");
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6);
	self.m_forone_btn = ccbNode:controlButtonForName("m_forone_btn");
	self.m_forone_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6);
	self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn");
	self.m_refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6);
	self.m_forten_btn = ccbNode:controlButtonForName("m_forten_btn");
	self.m_forten_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6);
	self.m_rule_btn = ccbNode:controlButtonForName("m_rule_btn");
	self.m_rule_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6);
	self.m_pos_sp=ccbNode:nodeForName("m_pos_sp");
	self.m_scale9sprite_select = ccbNode:spriteForName("m_scale9sprite_select");
	self.m_scale9sprite_select:setScale(1.2);

	--数量
	self.m_count_lab_tab={};
	local m_goods_count_lab=nil;
	for i=17,22 do 
		m_goods_count_lab=ccbNode:labelTTFForName("goods_count_lab"..i);
		self.m_count_lab_tab[i]=m_goods_count_lab;
	end

    --格子
	self.m_icon_sp_tab={};
	local m_icon_sp=nil;
	for i=1,22 do 
		m_icon_sp=ccbNode:spriteForName("m_icon_sp"..i);
		self.m_icon_sp_tab[i]=m_icon_sp;
	end
	
	--灯
	self.m_blink_node_tab={};
	local m_blink_node=nil;
	for i=1,14 do 
		m_blink_node=ccbNode:spriteForName("blink_node"..i);
		self.m_blink_node_tab[i]=m_blink_node;
	end

	--十连用展示masklayer触摸事件
	local function onTouch(eventType, x, y)
        if eventType == "began" then
        	if self.m_gachaAnimEndFlag==true then 
        		self.m_rewards_node:removeAllChildrenWithCleanup(true);
        		self.m_mask_layer:removeAllChildrenWithCleanup(true);
        		self.m_mask_layer:setTouchEnabled(false);
        		self.m_mask_layer:setVisible(false);
        		for i=1,14 do 
        			self.m_blink_node_tab[i]:setVisible(true);
        			self.m_blink_node_tab[i]:stopAllActions();
        		end
        		self:refreshUi();
        	end
            return true;
        elseif eventType == "ended" then
        end
    end
    --屏蔽后层的触摸
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
	self.m_root_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-5,true);
	self.m_root_layer:setTouchEnabled(true);
	self.m_mask_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-7,true);
	
	return ccbNode
end


--亮格子旋转一周
function game_indianaPan_pop.roundone(self)
	
	--每次都从同一位置开始转
	local pX,pY=self.m_pos_sp:getPosition();
	self.m_scale9sprite_select:setPosition(ccp(pX,pY));
	self.m_scale9sprite_select:setVisible(true);


	--跑马灯停止
	for i=1,14 do 
		self.m_blink_node_tab[i]:setVisible(true);
		self.m_blink_node_tab[i]:stopAllActions();
    end


    --触摸暂停
	self.m_forone_btn:setTouchEnabled(false);
	self.m_refresh_btn:setTouchEnabled(false);
	self.m_forten_btn:setTouchEnabled(false);

	--转动速度
	local outSpeed=tonumber('0.08');--转动速度,越小越快
	local innderSpeed=tonumber('0.06');--转动速度,越小越快

	--第二圈旋转到中奖位置
	local function roundtwo()
		local animArr = CCArray:create()

		--从22调到16
		local pX,pY=self.m_icon_sp_tab[16]:getPosition();
		animArr:addObject(CCPlace:create(ccp(pX,pY)));
		animArr:addObject(CCDelayTime:create(outSpeed));
		-- animArr:addObject(CCMoveTo:create(innderSpeed,ccp(pX0,pY0)));

		--从1到中奖位置
		for i=1,self.m_reward_index do  
			local pX,pY=self.m_icon_sp_tab[i]:getPosition();
			--减速
			if self.m_reward_index-i<=4 then
				innderSpeed=innderSpeed*1.5
			end

			   --animArr:addObject(CCMoveTo:create(innderSpeed,ccp(pX,pY)));
			animArr:addObject(CCPlace:create(ccp(pX,pY)));
			animArr:addObject(CCDelayTime:create(innderSpeed));
		end
		
		local function zhongjiang()
			if self.m_flag==false then --单抽
			
				game_util:rewardTipsByDataTable(self.reward);

				self.m_gachaAnimEndFlag=true;
				if self.m_reward_index>=17 and self.m_reward_index<=22 then --中了里圈，灯闪
					for i=1,14 do 
						self.m_blink_node_tab[i]:runAction(CCRepeatForever:create(CCBlink:create(0.4,1)));
					end
					local function newrefresh()
						self:refreshUi();
					end
					performWithDelay(self.m_startAnim_node,newrefresh,3.0)  --灯全部闪3秒
				else --没中直接刷新
					local function  newrefreshForone()
						self:refreshUi();
					end
					performWithDelay(self.m_startAnim_node,newrefreshForone,3.0) --等3秒刷新
				end
			
			else --十连
				self.m_gachaAnimEndFlag=true;

				--跑马灯
				for i=1,14 do
					self.m_blink_node_tab[i]:runAction(CCRepeatForever:create(CCBlink:create(0.4,1)));
				end
				--跑马灯

				self.m_scale9sprite_select:setVisible(false); --转几圈闪亮格子就不显示了，直接弹出中奖界面
				self:shilian();

			end

		end
		animArr:addObject(CCCallFunc:create(zhongjiang)) --中奖提示调用
		self.m_scale9sprite_select:runAction(CCSequence:create(animArr));
	end

	

	--亮框从中间开始，转一圈后进入roundtwo()
	local animArr = CCArray:create()

	for i=18,22 do  --从内圈18开始，转到22
		local pX,pY=self.m_icon_sp_tab[i]:getPosition();
		--animArr:addObject(CCMoveTo:create(outSpeed,ccp(pX,pY)));
		animArr:addObject(CCPlace:create(ccp(pX,pY)));
		animArr:addObject(CCDelayTime:create(outSpeed));
	end

	local pX,pY=self.m_icon_sp_tab[16]:getPosition(); --22-16过渡
	--animArr:addObject(CCMoveTo:create(outSpeed,ccp(pX,pY)));
	animArr:addObject(CCPlace:create(ccp(pX,pY)));
	animArr:addObject(CCDelayTime:create(outSpeed));

	for i=1,22 do  --转一圈
		local pX,pY=self.m_icon_sp_tab[i]:getPosition();
		--animArr:addObject(CCMoveTo:create(outSpeed,ccp(pX,pY)));
		animArr:addObject(CCPlace:create(ccp(pX,pY)));
		animArr:addObject(CCDelayTime:create(outSpeed));
	end

	animArr:addObject(CCCallFunc:create(roundtwo)) --转到22调用roundtwo()
	
	self.m_scale9sprite_select:runAction(CCSequence:create(animArr));

end

function game_indianaPan_pop.shilian( self)
	--背景层
	self.m_mask_layer:setVisible(true);
	self.m_mask_layer:setTouchEnabled(true);

	local viewSize=self.m_rewards_node:getContentSize();
	local params={};
	params.row=2;
	params.column=5;
	params.totalItem=10;
	params.viewSize = viewSize;
	--params.touchPriority=GLOBAL_TOUCH_PRIORITY-7;
	local itemSize=CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	params.newCell=function(tableView,index)

	--将返回的rewardtable取到1-10的table中
		local reward=self.rewardfroten_tab[index+1];--取出奖励,从0开始
		local cell=tableView:dequeueCell();
		if cell==nil then 
			cell=CCTableViewCell:new();
			cell:autorelease();
		end
		if cell then 
			cell:removeAllChildrenWithCleanup(true);

			local icon,name,count=game_util:getRewardByItemTable(reward);
			if icon then 
				icon:setPosition(ccp(itemSize.width/2,itemSize.height/2));
				icon:setScale(1.2);
				cell:addChild(icon);
				if name then 
					local tempLabel=game_util:createLabelTTF({text=name,color=ccc3(250,180,0)});
					tempLabel:setPosition(ccp(itemSize.width/2,itemSize.height/5));
					cell:addChild(tempLabel);
				end
				if  count then 
					local countLabel=game_util:createLabelTTF({text="x"..count,color=ccc3(255,255,255)});
					countLabel:setPosition(ccp(itemSize.width/2,itemSize.height/10));
					cell:addChild(countLabel,10,10);
				end
			end
		end
		return cell;
	end
	local tempRewardTable=TableViewHelper:create(params);
	-- local tempRewardTableX,tempRewardTableY=tempRewardTable:getPosition();
	-- local viewSize=CCDirector:sharedDirector():getVisibleSize();
	--tempRewardTable:setPosition(tempRewardTableX-40,tempRewardTableY);--奖励位置修正
	tempRewardTable:setScale(0);
	self.m_rewards_node:addChild(tempRewardTable,10,10);
	--奖励弹出效果
	local animArr = CCArray:create();
	self:scaleOut(animArr,1.0)
	tempRewardTable:runAction(CCSequence:create(animArr))
end



function game_indianaPan_pop.refreshUi2(self)

	--延时刷新
	local function callrefresh()
		game_util:addMoveTips({text = "Đã tạo mới"})
		self:refreshUi();
	end

	performWithDelay(self.m_startAnim_node,callrefresh,0.6);

	self.m_forone_btn:setTouchEnabled(false);
	self.m_refresh_btn:setTouchEnabled(false);
	self.m_forten_btn:setTouchEnabled(false);

	--图标退出效果
	for i=1,16 do 
		local animArr = CCArray:create();
		self:scaleIn(animArr);
		self.m_icon_sp_tab[i]:runAction(CCSequence:create(animArr))

	end
	

	for i=1,14 do 
		self.m_blink_node_tab[i]:setVisible(true);
		self.m_blink_node_tab[i]:stopAllActions();
	end
	
	-- --数量lab
	-- for i=17,22 do 
	-- 	local animArr = CCArray:create();
	-- 	self:scaleIn(animArr);
	-- 	self.m_count_lab_tab[i]:runAction(CCSequence:create(animArr))
	-- end
 	
--图标弹出
	local function jumpout()
		for i=1,16 do 
			local animArr = CCArray:create();
			self:scaleOut(animArr,1.2)
			self.m_icon_sp_tab[i]:runAction(CCSequence:create(animArr))	
		end

			--inner
		-- for i=17,22 do 
		-- 	local animArr = CCArray:create();
		-- 	self:scaleOut(animArr,1.5)
		-- 	self.m_icon_sp_tab[i]:runAction(CCSequence:create(animArr))		
		-- end


		-- for i=17,22 do 
		-- 	local animArr = CCArray:create();
		-- 	self:scaleOut(animArr,1.0)
		-- 	self.m_count_lab_tab[i]:runAction(CCSequence:create(animArr))
		-- end


	end

	
	performWithDelay(self.m_startAnim_node,jumpout,1.0)  --node:create()的话记得addchild()

end


--奖励触摸展示
function game_indianaPan_pop.createButton( self,tag,parentNode )
	local function onBtnCilck( event,target )
	    local tagNode = tolua.cast(target, "CCNode");
	    local btnTag = tagNode:getTag();
	
	    local info =nil;
	    if btnTag<=16 then
	   		info= self.m_out_rewardTable[btnTag];
	   	else
	   		info= self.m_inner_rewardTable[btnTag-16];
	   		info[3]=1;
	   	end
            if info then
            	--cclog2(info,"info ==")
                local tempType = info[1]
                if tempType == 6 then--道具
                    local itemId = info[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info[2]
                  
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else      --- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info})
                end
            end
	end
	local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
	button:setZoomOnTouchDown(false)
	button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
	button:setPosition(ccp(20,17));
	button:setOpacity(0)
	button:setScale(0.7)
	button:setTag(tag)
	parentNode:addChild(button,11);

end



--放大效果
function game_indianaPan_pop.scaleOut(self,animArr,maxScale)
	if animArr then 
		animArr:addObject(CCScaleTo:create(0.1,0.2));
		animArr:addObject(CCScaleTo:create(0.1,0.6));
		animArr:addObject(CCScaleTo:create(0.1,0.8));
		animArr:addObject(CCScaleTo:create(0.1,maxScale));
	end

end

--缩小效果
function game_indianaPan_pop.scaleIn(self,animArr)
	if animArr then 
		animArr:addObject(CCScaleTo:create(0.1,0.8));
		animArr:addObject(CCScaleTo:create(0.1,0.6));
		animArr:addObject(CCScaleTo:create(0.1,0.2));
		animArr:addObject(CCScaleTo:create(0.1,0));
	end

end

--refreshUi
function game_indianaPan_pop.refreshUi(self)
	self.m_forone_lab:setString("("..self.m_price..")")
	self.m_refresh_lab:setString("("..self.m_refresh_price..")")
	self.m_forten_lab:setString("("..self.m_price_10..")") --价格

	self.m_forone_btn:setTouchEnabled(true);
	self.m_refresh_btn:setTouchEnabled(true);
	self.m_forten_btn:setTouchEnabled(true);

	local score=self.m_tGameData.score or 0; --积分
	self.m_score_lab:setString(tostring(score));

	self.m_inner_rewardTable=self.m_tGameData.inner_reward or {};  --取出奖励
	self.m_out_rewardTable=self.m_tGameData.out_reward or {};
	
	self.m_scale9sprite_select:setVisible(false);

	for i=1,22 do 
		self.m_icon_sp_tab[i]:removeAllChildrenWithCleanup(true);
		self:createButton(i,self.m_icon_sp_tab[i])
	end

	   
		--奖励布局
		--outer
	for i=1,16 do 
		local reward=self.m_out_rewardTable[i];
		local icon,name,count=game_util:getRewardByItemTable(reward);
		local contenSize=self.m_icon_sp_tab[i]:getContentSize();
			
		if icon then 
			icon:setScale(0.5);
			self.m_icon_sp_tab[i]:addChild(icon);
			icon:setPosition(contenSize.width/2,contenSize.height/2);
		end 
		if count then
            local itemSize = self.m_icon_sp_tab[i]:getContentSize();
            local tempLabel = game_util:createLabelTTF({text = "x"..count,color = ccc3(255,255,255),fontSize = 8});
            tempLabel:setPosition(ccp(itemSize.width*0.7+5, itemSize.height*0.25-5))
            self.m_icon_sp_tab[i]:addChild(tempLabel);
        end

	end
		--inner
	for i=17,22 do 
		local reward=self.m_inner_rewardTable[i-16]; --传入的innerreward 1-6
		local icon,name,count=game_util:getRewardByItemTable(reward);
		local contenSize=self.m_icon_sp_tab[i]:getContentSize();
		if count==0 then 
			icon:setColor(ccc3(51,51,51));  --数量为0设置为灰色
		end
		if icon then 
			icon:setScale(0.5);
			self.m_icon_sp_tab[i]:addChild(icon);
			icon:setPosition(contenSize.width/2,contenSize.height/2);
			if self.m_count_lab_tab[i] then 
				self.m_count_lab_tab[i]:setString("x"..count);
			end
		end 
	end



		--跑马灯
	for i=1,14 do 
		self.m_blink_node_tab[i]:stopAllActions();
		self.m_blink_node_tab[i]:setVisible(true);
	end
			
	self.m_shared = 0;
	local indexForBlink=1;
	function tick(dt)
		if indexForBlink>1 then 
			self.m_blink_node_tab[indexForBlink-1]:setVisible(true);
			self.m_blink_node_tab[indexForBlink]:setVisible(false);
		end
		if indexForBlink==1 then 
			self.m_blink_node_tab[14]:setVisible(true);
			self.m_blink_node_tab[indexForBlink]:setVisible(false);
		end
		indexForBlink=indexForBlink+1;
		if indexForBlink>14 then 
			indexForBlink=1;
		end

			
	end
	self.m_shared=CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.05, false)
end



--初始化
function game_indianaPan_pop.init(self,t_params)
	t_params=t_params or {};

	if t_params.gameData and tolua.type(t_params.gameData)=="util_json" then 
		local data=t_params.gameData:getNodeWithKey("data");
		self.m_tGameData=json.decode(data:getFormatBuffer());
	
	else
        self.m_tGameData = t_params.gameData or {};

	end

 	self.m_out_rewardTable=self.m_tGameData.out_reward or {};
	self.m_inner_rewardTable=self.m_tGameData.inner_reward or {};
	self.m_refresh_price=self.m_tGameData.refresh_price or 0;
	self.m_price=self.m_tGameData.price or 0;
	self.m_price_10=self.m_tGameData.price_10 or 0;

	self.m_gachaAnimEndFlag=false;
	self.m_flag=false;
	
end


--scene的create
function game_indianaPan_pop.create(self,t_params)
	self:init(t_params);
	local scene = CCScene:create();
	scene:addChild(self:createUi());
	self:refreshUi();
	return scene;
end

return game_indianaPan_pop;