--- game_fate_refresh_pop 命运联协刷新

local game_fate_refresh_pop = {
    m_selectedHeroId=nil,
    m_selected_hero_infate=nil,
    m_btn_tab=nil,
    m_changeTo_index=nil,
    m_fate_toChange=nil,
    m_layer_list=nil,
    m_root_layer=nil,
    m_node_list=nil,
    m_spr_list_back=nil,
    m_label_fate_title_tab=nil,
    m_label_title_tab=nil,
    m_node_tab=nil,
    m_ccbNode=nil,
    m_curPage=nil,
    m_heroName=nil,
    m_fate_tab=nil,
    m_fate_card_tab=nil,
    m_fate_effect_tab=nil,
    m_fate_level_select=nil,
    m_fate_level_detail_select=nil,
    m_refreshed_i=nil,
    m_changeTo_card=nil,
    m_node_anim_tab=nil,
    m_spr_list_back2=nil,
};

--[[--
    销毁
]]
function game_fate_refresh_pop.destroy(self)
    -- body
    cclog("-----------------game_fate_refresh_pop destroy-----------------");
    self.m_selectedHeroId=nil;
    self.m_selected_hero_infate=nil;
    self.m_btn_tab=nil;
    self.m_changeTo_index=nil;
    self.m_fate_toChange=nil;
    self.m_layer_list=nil;
    self.m_root_layer=nil;
    self.m_node_list=nil;
    self.m_spr_list_back=nil;
    self.m_label_fate_title_tab=nil;
    self.m_label_title_tab=nil;
    self.m_node_tab=nil;
    self.m_ccbNode=nil;
    self.m_curPage=nil;
    self.m_heroName=nil;
    self.m_fate_tab=nil;
    self.m_fate_card_tab=nil;
    self.m_fate_effect_tab=nil;
    self.m_fate_level_select=nil;
    self.m_fate_level_detail_select=nil;
    self.m_refreshed_i=nil;
    self.m_changeTo_card=nil;
    self.m_node_anim_tab=nil;
    self.m_spr_list_back2=nil;

end
--[[--
    返回
]]


function game_fate_refresh_pop.back(self,type)
    game_scene:removePopByName("game_fate_refresh_pop");
    if self.btnCallFunc then
        self.btnCallFunc()
    end
    
end
--[[--
    读取ccbi创建ui
]]
function game_fate_refresh_pop.createUi(self)
    
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag >=101 and btnTag<=404 then  
            --点击对应的卡的idself.m_fate_card_tab[1][btnTag-100+1]
            local cardData,cardCfg = game_data:getCardDataById(self.m_selectedHeroId)
            if cardData.fate_change and next(cardData.fate_change) then
                game_util:addMoveTips({text="Chỉ được chuyển 1 thẻ trong 1 VM"})
            else
                local temp_i=math.modf(btnTag/100)
                local temp_j=btnTag%100+1
                self.m_fate_toChange=self.m_fate_tab[temp_i];--转换的命运id
               
                self.m_selected_hero_infate=self.m_fate_card_tab[temp_i][temp_j];  --选择的待转换的命运卡牌
           
                self:setBtnLight(btnTag)
            end
        
        elseif btnTag==902 then   --reset
            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text="Đã reset xong!"})
                self:refreshUi();
                self:setBtnEnable(true);
                self:back();
            end

             local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView()
                    
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_reset_fate"), http_request_method.GET, {major=self.m_selectedHeroId},"cards_reset_fate")
                    
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                   
                end,

                okBtnText = "OK",   
                cancelBtnText = string_config.m_btn_cancel,    
                text = tostring("Reset Vận Mệnh đã chuyển của thẻ?"),      
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-19,
            }
            game_util:openAlertView(t_params);
        
        elseif btnTag==901 then
                local cardData,cardCfg = game_data:getCardDataById(self.m_selectedHeroId)

                --转世
                local afterLifeId=nil;
                local afterLifeCfg=getConfig(game_config_field.afterlife)
                if afterLifeCfg:getNodeWithKey(tostring(self.m_changeTo_card)) then
                    local cfg=afterLifeCfg:getNodeWithKey(tostring(self.m_changeTo_card))
                    afterLifeId=cfg:getNodeWithKey("afterlife_id"):toStr()
                end


                local flag=false

                if self.m_changeTo_card ==nil then
                    game_util:addMoveTips({text="Chọn thẻ bài!"})
                    return;
                end

                 --todo  筛选命运重复的卡牌
                for i=1,#self.m_fate_card_tab do
                    for j=2,#self.m_fate_card_tab[i] do 
                        if self.m_fate_card_tab[i][j]==self.m_changeTo_card then
                            flag=true
                        end
                    end
                end
                if tostring(self.m_changeTo_card)== tostring(self.m_selected_hero_infate)  then
                    game_util:addMoveTips({text="Thẻ chuyển giống với thẻ Vận Mệnh gốc!"})
                elseif flag==true then 
                    game_util:addMoveTips({text="Thẻ đã chọn trùng với thẻ trong Vận Mệnh hiện tại!"})
                elseif  tostring(self.m_changeTo_card )==tostring(cardData["c_id"]) or tostring(afterLifeId)==tostring(cardData["c_id"]) then
                    game_util:addMoveTips({text="Thẻ đã chọn giống với thẻ hiện tại!!"})
                elseif cardData.fate_change and next(cardData.fate_change) then
                    game_util:addMoveTips({text="Đã chuyển xong, reset để chuyển tiếp!"})
                else --转换
                    local function responseMethod(tag,gameData)
                        self:back();
                        --self:setBtnEnable(false);
                        game_util:addMoveTips({text="Đã chuyển!"})

                    end

                    local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView()
                        
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_set_fate"), http_request_method.GET, {major=self.m_selectedHeroId,c_id= self.m_selected_hero_infate,change_id=self.m_changeTo_index,chain_id=self.m_fate_toChange},"cards_set_fate")
                        
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                       
                    end,

                    okBtnText = "OK",   
                    cancelBtnText = string_config.m_btn_cancel,    
                    text = tostring("Mỗi thẻ chỉ được chuyển 1 thẻ trong 1 VM, chuyển nhé?"),      
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-19,
                }
                game_util:openAlertView(t_params);
            

            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_fate_relation_refresh_pop.ccbi");
    
    self.m_root_layer = ccbNode:layerForName("layer_root");
    local btn_close=ccbNode:controlButtonForName("btn_close");
    btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12);

    local btn_ok=ccbNode:controlButtonForName("btn_ok")
    btn_ok:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12);

    local btn_reset=ccbNode:controlButtonForName("btn_reset");
    btn_reset:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12);

    self.m_layer_list=ccbNode:layerForName("layer_list");
    --self.m_node_list:setVisible(false)
    self.m_node_list=ccbNode:nodeForName("node_list");

    self.m_node_anim_tab={};
    for i=1,4 do 
        self.m_node_anim_tab[i]=ccbNode:nodeForName("node_anim_"..i);
    end

    self.m_spr_list_back=ccbNode:scale9SpriteForName("spr_list_back")
    self.m_spr_list_back:setVisible(true);

    self.m_spr_list_back2=ccbNode:scale9SpriteForName("spr_list_back2")
    self.m_spr_list_back2:setVisible(true);

    local label_need_coin=ccbNode:labelTTFForName("label_need_coin")
    local canBuy,pay = game_util:getCostCoinBuyTimes(44) --获取coin
    local coin_str =pay or "100";
    label_need_coin:setString("Tốn"..coin_str.."Xu")

    self.m_btn_tab={};
    for i=1,4 do
        self.m_btn_tab[i]={};
        for j=1,4 do
            self.m_btn_tab[i][j]=ccbNode:controlButtonForName("btn_"..i.."_"..j);
            self.m_btn_tab[i][j]:setVisible(false);
            self.m_btn_tab[i][j]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12);
        end
    end


    self.m_label_fate_title_tab={}
    for i=1,4 do
        self.m_label_fate_title_tab[i]=ccbNode:labelTTFForName("label_fate_title_"..i);
        self.m_label_fate_title_tab[i]:setVisible(false)
    end

    self.m_label_title_tab={};
    for i=1,4 do
        self.m_label_title_tab[i]={};
        for j=1,5 do 
            self.m_label_title_tab[i][j]=ccbNode:labelTTFForName("label_title_"..i.."_"..j);
            self.m_label_title_tab[i][j]:setVisible(false);
        end
    end

    self.m_node_tab={};
    for i=1,4 do
        self.m_node_tab[i]=ccbNode:nodeForName("node_"..i);
        self.m_node_tab[i]:setVisible(false);
    end
   

    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            return true;
        end
    end

--tableView的触摸关闭
    local function onTouch2(eventType,x,y)
        -- body
        if(eventType == "began") and self.m_layer_list:isVisible() then
           local realPos = self.m_node_list:getParent():convertToNodeSpace(ccp(x,y));
            
            if self.m_node_list:boundingBox():containsPoint(realPos) then

                return true;--intercept event
            else
                self.m_layer_list:setVisible(false)
                self.m_layer_list:setTouchEnabled(false)
                self.m_node_list:removeAllChildrenWithCleanup(true);
            end

            return false;
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_layer_list:setVisible(false);
    self.m_layer_list:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-13,true);
    self.m_layer_list:setTouchEnabled(false);

    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end


function game_fate_refresh_pop.setBtnEnable(self,flag)
    for i=1,4 do
        for j=1,4 do
             self.m_btn_tab[i][j]:setTouchEnabled(flag)
            
        end
    end
end


--已刷新
function game_fate_refresh_pop.setBtnLight2(self,btnTag)
    local btn_i =math.modf(btnTag/100)   --取整
  
    local btn_j=btnTag%100
    
    for i=1,4 do
        for j=1,4 do
            if  btn_i==i and btn_j==j then 
                self.m_btn_tab[i][j]:setHighlighted(true)
                self.m_btn_selected=self.m_btn_tab[i][j];
                self.m_fate_level_select=i
                self.m_fate_level_detail_select=j;
            else
                self.m_btn_tab[i][j]:setHighlighted(false)
            end
        end
    end
    --选中动画
        for i=1,4 do 
            self.m_node_anim_tab[i]:removeAllChildrenWithCleanup(true)
        end

          --选中动画
        local function onAnimSectionEnd( animNode, theId,theLabelName )
             animNode:playSection(theLabelName);
        end
        local mAnimNode= game_util:createBlenderAnim("mingyunzhuanhuan",1,true);  --混合高光动画
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd);
        if mAnimNode then
            mAnimNode:playSection("impact")
        end
        local pX,pY = self.m_btn_tab[btn_i][btn_j]:getPosition(); 
        self.m_node_anim_tab[btn_i]:addChild(mAnimNode);
        self.m_node_anim_tab[btn_i]:setPosition(ccp(pX,pY))
     
end

----设置按钮选中状态
function game_fate_refresh_pop.setBtnLight(self,btnTag)
        
    
        local btn_i =math.modf(btnTag/100)   --取整
   
        local btn_j=btnTag%100
     
        for i=1,4 do
            for j=1,4 do
                if  btn_i==i and btn_j==j then 
                    self.m_btn_tab[i][j]:setHighlighted(true)
                    self.m_btn_selected=self.m_btn_tab[i][j];
                    self.m_fate_level_select=i
                    self.m_fate_level_detail_select=j;
                else
                    self.m_btn_tab[i][j]:setHighlighted(false)
                end
            end
        end

 --选中动画
        for i=1,4 do 
            self.m_node_anim_tab[i]:removeAllChildrenWithCleanup(true)
        end

          --选中动画
        local function onAnimSectionEnd( animNode, theId,theLabelName )
             animNode:playSection(theLabelName);
        end
        local mAnimNode= game_util:createBlenderAnim("mingyunzhuanhuan",1,true);  --混合高光动画
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd);
        if mAnimNode then
            mAnimNode:playSection("impact")
        end
        local pX,pY = self.m_btn_tab[btn_i][btn_j]:getPosition(); 
        self.m_node_anim_tab[btn_i]:addChild(mAnimNode);
        self.m_node_anim_tab[btn_i]:setPosition(ccp(pX,pY))
      
        -- local pX,pY = self.m_btn_tab[btn_i][btn_j]:getPosition();
        -- local Pos = self.m_btn_tab[btn_i][btn_j]:getParent():convertToWorldSpace(ccp(pX,pY));
       
        -- --self.m_node_list:setPosition(Pos);
        self.m_layer_list:setVisible(true);
        self.m_layer_list:setTouchEnabled(true);

        self:getHeroFate();

        self.m_node_list:removeAllChildrenWithCleanup(true);
        local tableView=self:createTableView();
        self.m_node_list:addChild(self.m_spr_list_back,100,100)
        self.m_node_list:addChild(self.m_spr_list_back2,99,99)
        self.m_node_list:addChild(tableView,111,111);
end



---创建tableView
function  game_fate_refresh_pop.createTableView(self)
    local fate_change_cfg=getConfig(game_config_field.fate_change)
    local fate_change_count=fate_change_cfg:getNodeCount();

    for i=1,fate_change_count do
        local cfg=fate_change_cfg:getNodeWithKey(tostring(i))
    
        local cardId= cfg:getNodeWithKey("card_id"):toStr();  --卡牌id

        local effect=cfg:getNodeWithKey("add_ability"):toInt();
       
    end
    local row_num=1;
    row_num= math.ceil(fate_change_count/5) --向上取整

    local viewSize=self.m_node_list:getContentSize();
    local cardsCount=fate_change_count;
    local params = {};
    params.viewSize = viewSize;
    params.row = row_num;  --hang
    params.column = 5; --列
    params.totalItem = cardsCount;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority=GLOBAL_TOUCH_PRIORITY-99;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row );
    params.newCell = function(tableView,index) 
     local cell = tableView:dequeueCell()
        if cell==nil then 
            cell=CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then 
            cell:removeAllChildrenWithCleanup(true);
            local cfg=fate_change_cfg:getNodeWithKey(tostring(index+1));
            if cfg then
                local cardId= cfg:getNodeWithKey("card_id"):toStr();  --卡牌id
                local icon=game_util:createCardIconByCid(cardId);
              
                if icon then 
                    icon:setPosition(ccp(itemSize.width/2,itemSize.height/2+6));
                    icon:setScale(0.8);
                    cell:addChild(icon);         

                    --效果
                    local effect=cfg:getNodeWithKey("add_ability"):toInt();
                    if effect>=0 then
                        effect="+"..effect.."%"
                    else
                        effect=effect.."%"
                    end
                    local tempLabel = game_util:createLabelTTF({text = effect,color = ccc3(255,255,255),fontSize = 14});
                    tempLabel:setPosition(ccp(itemSize.width/2, itemSize.height/10+1))
                    cell:addChild(tempLabel)
                end
            end
        end
        return cell;
    end
 params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then  
            local fate_change_cfg=getConfig(game_config_field.fate_change)
            local cfg=fate_change_cfg:getNodeWithKey(tostring(index+1));
            
            local cardId= cfg:getNodeWithKey("card_id"):toStr();
            self.m_changeTo_index=tostring(index+1);
            self.m_changeTo_card=cardId; --转换成的卡牌
            
            local effect=cfg:getNodeWithKey("add_ability"):toInt();
            if effect>=0 then
                effect="+"..tostring(effect)
            end


            local character_detail_cfg = getConfig(game_config_field.character_detail);
            local itemCfg = character_detail_cfg:getNodeWithKey(tostring(cardId))
            
            self.m_heroName=itemCfg:getNodeWithKey("name"):toStr();
         --选择卡牌提示
             local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    self.m_layer_list:setVisible(false);
                    self.m_layer_list:setTouchEnabled(false);
                    self.m_node_list:removeAllChildrenWithCleanup(true);
                    game_util:setCCControlButtonTitle(self.m_btn_selected,self.m_heroName or "")
                    self.m_selected_flag=true;
                    self:setEffectLabel(effect)  
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                   
                end,
                okBtnText = "OK",   
                cancelBtnText = string_config.m_btn_cancel,    
                text = tostring(self.m_heroName..":Thuộc tính VM"..tostring(effect).."%"),      
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-19,
            }
            game_util:openAlertView(t_params);
        end
    end

    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);

end


----取卡牌命运数据
function game_fate_refresh_pop.getHeroFate(self)

    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local cardData,cardCfg = game_data:getCardDataById(self.m_selectedHeroId)

    local chain_cfg = getConfig(game_config_field.chain); 
    local chain = cardCfg:getNodeWithKey("chain");
    local chainCount = chain:getNodeCount();
    -- if chainCount > 4 then
    --     game_util:addMoveTips({text = " 命运配置多了  "})
    -- end
    chainCount = math.min(chainCount,4)
    self.m_fate_tab={}; --命运id
    self.m_fate_card_tab={}; --命运相关卡牌id
    self.m_fate_effect_tab={};--效果
   cclog2(chain,"     chain    ------------- >>>>>>>>> ")
   --遍历每条命运
    for i=1,chainCount do
        self.m_fate_card_tab[i]={};
        local chainId = chain:getNodeAt(i-1):toStr(); --9401
        local chainItemCfg = chain_cfg:getNodeWithKey(chainId); --9401 in chain
        
        if chainItemCfg then
            local name = chainItemCfg:getNodeWithKey("name"):toStr(); --绝命狂飙
            local des = chainItemCfg:getNodeWithKey("des"):toStr(); --与card2和card3同时出场时物攻、魔攻、速度和生命+20%，防御+10%
            local effect = chainItemCfg:getNodeWithKey("effect")
            local data = chainItemCfg:getNodeWithKey("data")--9400,9100,8800
            
            local dataCount = data:getNodeCount();--3
            local condition_sort = chainItemCfg:getNodeWithKey("condition_sort"):toInt();--0
            if condition_sort == 0 then
                
                table.insert(self.m_fate_tab,chainId);--该卡牌的所有的命运id

                for j=1,dataCount do
                    self.m_fate_card_tab[i][j]=data:getNodeAt(j-1):toStr(); --命运卡牌id
                    self.m_fate_effect_tab[i]=effect;

                    local itemCfg = character_detail_cfg:getNodeWithKey(data:getNodeAt(j-1):toStr())
                  
                    if itemCfg  then
                        local heroName=itemCfg:getNodeWithKey("name"):toStr();

                        --刷新过的显示
                         if cardData.fate_change and next(cardData.fate_change)then
                           
                            if chainId ==tostring(cardData.fate_change["chain_id"]) then
                                if data:getNodeAt(j-1):toStr() == tostring(cardData.fate_change.c_id1) then
                                    local itemCfg2=character_detail_cfg:getNodeWithKey(tostring(cardData.fate_change.c_id2))
                                    heroName=itemCfg2:getNodeWithKey("name"):toStr();
                                    self.m_refreshed_i=i;
                                    self.m_refreshed_j=j-1; 
                                end
                            end
                            
                        end

                        cclog2(data:getNodeAt(j-1):toStr(),"data:getNodeAt(j-1):toStr()")
                        cclog2(cardData.c_id,"cardData.c_id")
                        --if data:getNodeAt(j-1):toStr() == tostring(cardData.c_id )then --第一个是自己
                        if j==1 then
                        else
                        --CCLuaLog(itemCfg:getNodeWithKey("name"):toStr());

                        --设置按钮名称
                            if i > 4 or j > 4 then
                                break
                            end
                            cclog("   i   == " .. i .. "    j  ==  " .. j .. "     heroName  == " .. heroName)
                            game_util:setCCControlButtonTitle(self.m_btn_tab[i][j-1],heroName or "")--第一个是自己，不取
                            self.m_btn_tab[i][j-1]:setVisible(true)

                            --设置命运名称
                            self.m_label_fate_title_tab[i]:setString(name);
                            self.m_label_fate_title_tab[i]:setVisible(true)
                        end
                    end
                end
            end
        end
    end
    self:setEffectLabel();
end


--效果label
function game_fate_refresh_pop.setEffectLabel(self,percent)


    local tableCount=#self.m_fate_tab;
    local  per= 0;
    local effect=0;
  
    --设置几栏
    for i=1,tableCount do
        self.m_node_tab[i]:setVisible(true)
    end

--[[
2- 防御
3-速度
4-生命
1-魔攻
0-物攻
]]
     local cardData,cardCfg = game_data:getCardDataById(self.m_selectedHeroId)
     --如果刷新过
    if cardData.fate_change and next(cardData.fate_change) then
        local fate_change_cfg=getConfig(game_config_field.fate_change)
        local change_id=cardData.fate_change["change_id"]
  
        local cfg=fate_change_cfg:getNodeAt(change_id-1);
         effect=cfg:getNodeWithKey("add_ability"):toInt();
    
    end


    --设置效果label
    local effect_count=#self.m_fate_effect_tab;

  

    for i=1,effect_count do
        local data= json.decode(self.m_fate_effect_tab[i]:getFormatBuffer());

        if self.m_fate_level_select ==i then  --不是当前选择命运属性不改
            per =percent or 0;
        else
            per=0
        end

    


        --刷新过的属性
        if self.m_refreshed_i~=100 then
            if self.m_refreshed_i==i then
                per=effect or 0
                
            end
        end

        for j=1,#data do
           
            if data[j][1] ==0 then  --
                self.m_label_title_tab[i][j]:setVisible(true);
                self.m_label_title_tab[i][j]:setString("Vật công+"..tostring(data[j][2]/10+per).."%");
            elseif data[j][1]==1 then
                self.m_label_title_tab[i][j]:setVisible(true);
                self.m_label_title_tab[i][j]:setString("Ma Công+"..tostring(data[j][2]/10+per).."%");
            elseif data[j][1]==2 then
                self.m_label_title_tab[i][j]:setVisible(true);
                self.m_label_title_tab[i][j]:setString("Phòng ngự+"..tostring(data[j][2]/10+per).."%");
            elseif data[j][1]==3 then
                self.m_label_title_tab[i][j]:setVisible(true);
                self.m_label_title_tab[i][j]:setString("Tốc độ+"..tostring(data[j][2]/10+per).."%");
            elseif data[j][1]==4 then
                self.m_label_title_tab[i][j]:setVisible(true);
                self.m_label_title_tab[i][j]:setString("HP+"..tostring(data[j][2]/10+per).."%");
            
            end
        end
    end




end




--[[--
    刷新ui
]]
function game_fate_refresh_pop.refreshUi(self)
    
    self:getHeroFate();
    --self:createTableView();
    local cardData,cardCfg=game_data:getCardDataById(self.m_selectedHeroId)
    
    --如果已经刷新过，则设置按钮状态
    if cardData.fate_change and next(cardData.fate_change) then
       
        self:setBtnLight2(self.m_refreshed_i*100+self.m_refreshed_j);
        self.m_btn_tab[self.m_refreshed_i][self.m_refreshed_j]:setTouchEnabled(false); --高亮的不能触摸
        --self:setBtnEnable(false);
    end

end

--[[--
    初始化
]]
function game_fate_refresh_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tParams = t_params;
    self.m_selectedHeroId=t_params.id;  --选择转换的卡牌
    cclog2(self.m_selectedHeroId,"self.m_selectedHeroId is ")
    self.btnCallFunc=t_params.callBackFunc;
    self.m_btn_selected=nil;
    self.m_selected_flag=false;
    self.m_refreshed_i=100;
    self.m_refreshed_j=100;


 
end

--[[--
    创建ui入口并初始化数据
]]
function game_fate_refresh_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_fate_refresh_pop;