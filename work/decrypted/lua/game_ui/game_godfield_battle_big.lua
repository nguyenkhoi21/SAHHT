---  神域战斗场景

local game_godfield_battle_big = {
    m_tGameData = nil,
    m_tiaoguo_btn = nil,
    rightIcon_node = nil,
    leftIcon_node = nil,
    vsAnim_node = nil,
    leftAnim_node = nil,
    rightAnim_node = nil,
    openAnim_node = nil,
    sort= nil,
    m_icon_sprite_1 = nil,
    m_icon_sprite_2 = nil,
    m_reslut_sprite_1 = nil,
    m_reslut_sprite_2 = nil,
    m_name_label_1 = nil,
    m_name_label_2 = nil,
    cid = nil,
    enemy_cid = nil,
    m_itemData = nil,
    m_battle_num = nil,
    m_enemyData_tab = nil,
    zhenxing_node1 = nil,
    zhenxing_node2 = nil,
    myVictory_num = nil,
    emenyVictory_num = nil,
    m_iAnim2 = nil,
    m_iAnim1 = nil,
    m_iAnim = nil,
    refreshUi_times = nil,
    m_first_sp = nil,
    left_starNode = nil,
    right_starNode = nil,
    m_playNum = nil,
    log_list = nil,
    my_flag = nil,
    m_openType = nil,
    pvp_reward = nil,
    nightmareReward = nil,
};
--[[--
    销毁ui
]]
function game_godfield_battle_big.destroy(self)
    -- body
    cclog("-----------------game_godfield_battle_big destroy-----------------");
    self.m_tGameData = nil;
    self.m_tiaoguo_btn = nil;
    self.rightIcon_node = nil;
    self.leftIcon_node = nil;
    self.vsAnim_node = nil;
    self.leftAnim_node = nil;
    self.rightAnim_node = nil;
    self.openAnim_node = nil;
    self.sort = nil;
    self.m_icon_sprite_1 = nil;
    self.m_icon_sprite_2 = nil;
    self.m_reslut_sprite_1 = nil;
    self.m_reslut_sprite_2 = nil;
    self.m_name_label_1 = nil;
    self.m_name_label_2 = nil;
    self.cid = nil;
    self.enemy_cid = nil;
    --self.m_enemyData_tab = nil;
    self.m_battle_num = nil;
    self.m_enemyData_tab = nil;
    self.zhenxing_node1 = nil;
    self.zhenxing_node2 = nil;
    self.myVictory_num = nil;
    self.emenyVictory_num = nil;
    self.m_iAnim2 = nil;
    self.m_iAnim1 = nil;
    self.m_iAnim = nil;
    self.m_first_sp = nil;
    self.left_starNode = nil;
    self.right_starNode = nil;
    self.refreshUi_times = nil;
    self.m_playNum = nil;
    self.m_itemData = nil;
    self.log_list = nil;
    self.my_flag = nil;
    self.m_openType = nil;
    self.pvp_reward = nil;
    self.nightmareReward = nil;
end
--[[--
    返回
]]
function game_godfield_battle_big.back(self,backType)

    local params = {}
    params.sort = self.sort
    local screenShoot = game_util:createScreenShoot();
    screenShoot:retain();
    local function endCallFunc( )
        screenShoot:release();
        self:destroy();
    end
    game_data:setGodfieldData(self.log_list)
    if self.m_openType then
        game_data:setNightmareReward(self.pvp_reward);
        game_scene:enterGameUi("game_godfield_battle_result",{gameData = self.log_list,screenShoot = screenShoot,mType = self.m_openType,pvp_reward = self.pvp_reward,nightmareReward = self.nightmareReward},{endCallFunc = endCallFunc})
    else
        game_scene:enterGameUi("game_godfield_battle_result",{gameData = self.log_list,screenShoot = screenShoot,flag = self.my_flag,pvp_reward = self.pvp_reward},{endCallFunc = endCallFunc})
    end
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_battle_big.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 101 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    if self.m_openType == "nightmare" or self.m_openType == "expedition" then
        ccbNode:openCCBFile("ccb/ui_godfield_battle_big2.ccbi");
    else
        ccbNode:openCCBFile("ccb/ui_godfield_battle_big.ccbi");
    end
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.m_tiaoguo_btn = ccbNode:controlButtonForName("m_tiaoguo_btn")
    self.vsAnim_node = ccbNode:nodeForName("vsAnim_node");
    self.openAnim_node = ccbNode:nodeForName("openAnim_node");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_icon_sprite_1 = ccbNode:spriteForName("m_icon_sprite_1")
    self.m_icon_sprite_2 = ccbNode:spriteForName("m_icon_sprite_2")
    self.m_reslut_sprite_1 = ccbNode:spriteForName("m_reslut_sprite_1")
    self.m_reslut_sprite_2 = ccbNode:spriteForName("m_reslut_sprite_2")
    self.m_name_label_1 = ccbNode:labelTTFForName("m_name_label_1")
    self.m_name_label_2 = ccbNode:labelTTFForName("m_name_label_2")
    self.zhenxing_node1 = ccbNode:nodeForName("zhenxing_node1")
    self.zhenxing_node2 = ccbNode:nodeForName("zhenxing_node2")
    self.m_first_sp = ccbNode:spriteForName("m_first_sp")
    local right_Node = nil
    local left_Node = nil
    self.leftAnim_node = {}
    self.rightAnim_node = {}
    for i=1,5 do
        right_Node = ccbNode:nodeForName("rightAnim_node" .. i)
        left_Node = ccbNode:nodeForName("leftAnim_node" .. i)
        self.leftAnim_node[i] = {left_Node = left_Node}
        self.rightAnim_node[i] = {right_Node = right_Node}
    end
    local right_star,left_star = nil
    self.left_starNode = {}
    self.right_starNode = {}
    for i=1,3 do
        left_star = ccbNode:spriteForName("m_star_sp" .. i)
        right_star = ccbNode:spriteForName("m_star_sp2" .. i)
        self.left_starNode[i] = {left_star = left_star}
        self.right_starNode[i] = {right_star = right_star}
    end
    return ccbNode;

end
-- --[[--
--     获取战斗结果的数据
-- ]]
function game_godfield_battle_big.getBattleResultData(self)
    local x = self.log_list["log_dict"].log_list
    return x 
end

--[[--
    星星
]]
function game_godfield_battle_big.star( self,is_win )
    if is_win == 1 then
        if self.myVictory_num == 1 then 
            self.left_starNode[1].left_star:setVisible(true)
        elseif self.myVictory_num == 2 then
            self.left_starNode[1].left_star:setVisible(true)
            self.left_starNode[2].left_star:setVisible(true)
        elseif self.myVictory_num == 3  then
            self.left_starNode[1].left_star:setVisible(true)
            self.left_starNode[2].left_star:setVisible(true)
            self.left_starNode[3].left_star:setVisible(true)
        end
        self.myVictory_num  = self.myVictory_num +1 
    else
        if self.emenyVictory_num == 1 then 
            self.right_starNode[1].right_star:setVisible(true)
        elseif self.emenyVictory_num == 2 then
            self.right_starNode[1].right_star:setVisible(true)
            self.right_starNode[2].right_star:setVisible(true)
        elseif self.emenyVictory_num == 3  then
            self.right_starNode[1].right_star:setVisible(true)
            self.right_starNode[2].right_star:setVisible(true)
            self.right_starNode[3].right_star:setVisible(true)
        end
        self.emenyVictory_num  = self.emenyVictory_num +1 
    end
    self.m_battle_num = self.m_battle_num + 1
    -- body
end
--[[--
    获取胜利或失败的场次
]]
function game_godfield_battle_big.getVictory( self,i )
    local m_log_list = self:getBattleResultData() or {}
    --cclog2(self.log_list,"getVictory i ===== ")
    local itemData = m_log_list[i] or {}
    --cclog2(itemData,"itemData --- ")
    --cclog2(itemData.is_win,"itemData.is_win --- ")
    local is_win = itemData.is_win or 0
    --cclog2(is_win,"getVictory is_win")
    return is_win

end
function game_godfield_battle_big.battleAnim( self )
    self.m_playNum = 1 +  self.m_playNum
    --cclog2(self.m_playNum,"battleAnim === ")
    local postab = {}
    local posX1,posY1 = self.zhenxing_node1:getPosition()
    local posX2,posY2 = self.zhenxing_node2:getPosition()
        local function animEnd1(animNode,theId,labelName)
        end
        local function animEnd(animNode,theId,labelName)
            if labelName=="kaizhang" then
                animNode:playSection("jingong2");
                local animArr = CCArray:create();
                local function animEndCallFunc()
                    self.zhenxing_node2:setVisible(false)
                    self.zhenxing_node1:setVisible(false)
                end
                animArr:addObject(CCMoveTo:create(0.5,(ccp(160,30))));
                animArr:addObject(CCCallFunc:create(animEndCallFunc));
                self.zhenxing_node1:runAction(CCSequence:create(animArr));
                local animArr2 = CCArray:create();
                local function animEndCallFunc2()
                end
                animArr2:addObject(CCMoveTo:create(0.5,(ccp(410,30))));
                animArr2:addObject(CCCallFunc:create(animEndCallFunc2));
                self.zhenxing_node2:runAction(CCSequence:create(animArr2));
                
            elseif labelName=="jingong2" then--待机
                animNode:playSection("dadou2");
                self.m_iAnim1:playSection("dadou2@1");
                self.m_iAnim2:playSection("dadou2@2");
            elseif labelName== "dadou2" then--双方掉血并且在双方之间（即舞台正中间）播guozhanhuoguang2
                self.zhenxing_node1:setVisible(true)
                self.zhenxing_node2:setVisible(true)
                local animArr = CCArray:create();
                local function animEndCallFunc()
                    --cclog2(self.m_battle_num,"self.m_battle_num === ")
                   local is_win = self:getVictory(self.m_battle_num)
                   if is_win == 1 then
                       self.zhenxing_node2:setVisible(false)
                       animNode:playSection("siwang3");--攻击死亡
                   else
                        self.zhenxing_node1:setVisible(false)
                        animNode:playSection("siwang4");
                   end
                end
                animArr:addObject(CCMoveTo:create(0.5,(ccp(posX1,posY1))));
                animArr:addObject(CCCallFunc:create(animEndCallFunc));
                self.zhenxing_node1:runAction(CCSequence:create(animArr));
                local animArr2 = CCArray:create();
                local function animEndCallFunc2()
                end
                animArr2:addObject(CCMoveTo:create(0.5,(ccp(posX2,posY2))));
                animArr2:addObject(CCCallFunc:create(animEndCallFunc2));
                self.zhenxing_node2:runAction(CCSequence:create(animArr2));
           
            --------------------防守方死亡
            elseif labelName== "siwang3" then--防守方死亡
                self:star(1)
                self.zhenxing_node1:setVisible(true)
                self.zhenxing_node2:setVisible(true)
                if self.refreshUi_times<4 then
                  
                    self.vsAnim_node:removeAllChildrenWithCleanup(true)
                    self:refreshUi(self.refreshUi_times) 
                else
                    self.m_playNum = 1 +  self.m_playNum  
                end
                if  self.m_playNum == 5 then
                        self:back()
                end

            elseif labelName== "siwang4" then--攻击方死亡
                --cclog2(self.m_playNum,"battleAnim 3=== ")
                self:star(0)
                self.zhenxing_node1:setVisible(true)
                self.zhenxing_node2:setVisible(true)
                if self.refreshUi_times<4 then
                    
                    self.vsAnim_node:removeAllChildrenWithCleanup(true)
                    self:refreshUi(self.refreshUi_times) 
                else
                       self.m_playNum = 1 +  self.m_playNum
                end
                
                if  self.m_playNum == 5 then
                        self:back()
                end
            end
        end
    self.m_iAnim = game_util:createBlenderAnim("guozhandonghua2" ,1, false);  
     --高光1
    self.m_iAnim1 = game_util:createBlenderAnim("guozhandonghua2" ,1, true);
    self.m_iAnim1:registerScriptTapHandler(animEnd);
     --高光2
    self.m_iAnim2 = game_util:createBlenderAnim("guozhandonghua2" ,1, false);
    self.m_iAnim2:registerScriptTapHandler(animEnd);
    self.m_iAnim:registerScriptTapHandler(animEnd);
     self.m_iAnim:playSection("kaizhang");
     self.m_iAnim1:playSection("kaizhang@1");
     self.m_iAnim2:playSection("kaizhang@2");

    self.vsAnim_node:addChild(self.m_iAnim)
    self.vsAnim_node:addChild(self.m_iAnim1)
    self.vsAnim_node:addChild(self.m_iAnim2)
end
--[[--
    创建角色头像
]]
function game_godfield_battle_big.createPlayerIcon(self,i)
    local log_list = self:getBattleResultData()
    self.m_icon_sprite_1:removeAllChildrenWithCleanup(true)
    self.m_icon_sprite_2:removeAllChildrenWithCleanup(true)
    --cclog2(log_list,"log_list === ")
    local itemData = log_list[i] or {}
    self.m_name_label_1:setString(tostring(itemData.attacker))
    self.m_name_label_2:setString(tostring(itemData.defender))

    -- CCLuaLog("att = " .. itemData.attacker)
    -- CCLuaLog("def = " .. itemData.defender)

    local tempSize = self.m_icon_sprite_1:getContentSize();
    local tempIcon = game_util:createPlayerIconByRoleId(itemData.attacker_role)
    if tempIcon then
        tempIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
        self.m_icon_sprite_1:addChild(tempIcon)
    end
    local tempIcon = game_util:createPlayerIconByRoleId(itemData.defender_role)
    if tempIcon then
        tempIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
        self.m_icon_sprite_2:addChild(tempIcon)
    end
    local is_win = itemData.is_win or 0
end
--[[--
    敌方阵容的cid
]]
function game_godfield_battle_big.getEnemyCid( self )
    if self.my_flag then
        self.m_enemyData_tab = {}
        for i=1,3 do
            local alignment_info = self.log_list.alignment_info[tostring(i)]
            self.m_enemyData_tab[i] = alignment_info
        end
    else
        self.m_enemyData_tab = {}
        for i=1,3 do
            local alignment_info = self.m_tGameData.alignment_info[tostring(i)]
            self.m_enemyData_tab[i] = alignment_info
        end
    end

end
--[[--
    自己阵容的cid
]]
function game_godfield_battle_big.getCid(self)
    if self.my_flag then
        local god_field_ids = self.log_list.god_field_ids

        for i =1,3 do
            self.cid[i] = god_field_ids[tostring(i)]
        end
    else
        local god_field_ids = self.m_tGameData.god_field_ids

        for i =1,3 do
            self.cid[i] = god_field_ids[tostring(i)]
        end
    end
    -- cclog2(self.cid,"cid === ")
end

--[[--
    创建卡牌动画序列
]]
function game_godfield_battle_big.createAnimSequence(self,animFile,animId,cardData,cardCfg,falg)
    local m_iAnim = game_util:createIdelAnim(animFile,animId,cardData,cardCfg);
    local x = 1
    local function animEnd(animNode,theId,lableName)
        if lableName == anim_label_name_cfg.daiji then
            -- animNode:playSection(anim_label_name_cfg.gongji1);
            if x == 2 and falg == true then
                -- self.leftAnim_node:setVisible(false)
                -- self.rightAnim_node:setVisible(false)
                -- self.m_battle_num = self.m_battle_num + 1
                -- if self.m_battle_num < 4 then
                --     self:createVSanim(self.m_battle_num,self.leftAnim_node,self.rightAnim_node)
                -- end
            end
            x = x+1
            game_anim:playSection(m_iAnim,anim_label_name_cfg.daiji);
        elseif lableName == anim_label_name_cfg.gongji1 then
            -- animNode:playSection(anim_label_name_cfg.gongji2);
            game_anim:playSection(m_iAnim,anim_label_name_cfg.gongji2);
        elseif lableName == anim_label_name_cfg.gongji2 then
            -- animNode:playSection(anim_label_name_cfg.daiji);
            game_anim:playSection(m_iAnim,anim_label_name_cfg.daiji);
        end
    end
    if m_iAnim then
        m_iAnim:registerScriptTapHandler(animEnd);
        -- m_iAnim:playSection(anim_label_name_cfg.daiji);
        game_anim:playSection(m_iAnim,anim_label_name_cfg.daiji);
        m_iAnim:setScale(0.7);
    end
    return m_iAnim;
end
--[[--
    传自己的数据
]]
function game_godfield_battle_big.getMyData(self,x)
    local myData = self.cid[x]
    local num  = 1
    local tab = {}
    local ling = tostring(0)
    local yi = tostring(-1)
    for i=1,9 do
        if myData[i] ~= ling and myData[i] ~= yi and num < 6 then
            tab[num] = myData[i]
            num = num + 1
        end
    end
    if num< 5 then
        for i=1,5 do
            self:createMyVSanim(i,tab,self.leftAnim_node[i].left_Node)
        end
    else
        for i=1,5 do
            self:createMyVSanim(i,tab,self.leftAnim_node[i].left_Node)
        end
    end
    -- cclog2(myData,"myData == ")

end

--[[--
    创建自己的五个卡牌
]]
function game_godfield_battle_big.createMyVSanim( self,i,myData,parentNodeL )
    parentNodeL:removeAllChildrenWithCleanup(true)
    -- cclog2(myData,"myData[i]  ==== ")
    local ling = tostring(0)
    local yi = tostring(-1)
    if myData[i] ~= nil and myData[i] ~= ling and myData[i] ~= yi then
        -- cclog2(myData[i],"myDat``   1a[i] === ")
        local cardData,heroCfg = game_data:getCardDataById(myData[i])
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        local animNode1 = self:createAnimSequence(ainmFile,0,cardData,heroCfg,true);
        if animNode1 then
            animNode1:setRhythm(1);
            game_anim:playSection(animNode1 , anim_label_name_cfg.daiji);
            animNode1:setAnchorPoint(ccp(0.5,0));
            parentNodeL:addChild(animNode1);
        end
    end
end
--[[--
    传敌人数据
]]
function game_godfield_battle_big.getEmenyData(self,x)
    local emenyData = self.m_enemyData_tab[x]
    for i=1,5 do
        self:createVSanim(i,emenyData,self.rightAnim_node[i].right_Node)
    end
end
--[[--
    创建敌方五个卡牌的动画
]]
function game_godfield_battle_big.createVSanim( self,i,itemData,parentNodeR )
    parentNodeR:removeAllChildrenWithCleanup(true)
    if itemData and next(itemData) then
        local character_detail_cfg = getConfig("character_detail");
        local cardData1 = {}
        if self.my_flag then
             table.insert(cardData1,itemData[i]);
        else
            cardData1 = itemData[i];
        end
        if cardData1 and next(cardData1) then 
            local heroCfg1 = nil;

            if self.my_flag then
                for i=1,#itemData do
                    if itemData[i]== "0" then
                        table.remove(itemData,i)
                    end
                end
                local enemy_c_id = self:lua_string_split(itemData[i]) or {};
                -- cclog2(enemy_c_id,"enemy_c_idenemy_c_idenemy_c_id")
                -- cclog2(itemData[i],"itemData[i]itemData[i]")
                if enemy_c_id[1] ~= 1 and enemy_c_id[1] ~= "1" and  enemy_c_id[2] then
                    heroCfg1 = character_detail_cfg:getNodeWithKey(enemy_c_id[1])
                end
            else
                -- cclog2(itemData[i].c_id,"itemData[i].c_id ---- ")
                if string.sub(itemData[i].c_id,1,4) == "1800" and string.len(itemData[i].c_id) == 7 and self.m_openType == "nightmare" then
                    local new_fight_enemy = json.decode(getConfig(game_config_field.new_fight_enemy):getFormatBuffer())
                    heroCfg1 = character_detail_cfg:getNodeWithKey(new_fight_enemy[itemData[i].c_id].c_id)
                elseif string.sub(itemData[i].c_id,1,4) == "1800" and string.len(itemData[i].c_id) == 7 and self.m_openType == "expedition" then
                    local new_fight_enemy = json.decode(getConfig(game_config_field.new_fight_enemy):getFormatBuffer())
                    heroCfg1 = character_detail_cfg:getNodeWithKey(new_fight_enemy[itemData[i].c_id].c_id)
                else
                    heroCfg1 = character_detail_cfg:getNodeWithKey(itemData[i].c_id)
                end
            end
            local animNode2 = nil;
            if heroCfg1 then
                local ainmFile = heroCfg1:getNodeWithKey("animation"):toStr();
                animNode2 = self:createAnimSequence(ainmFile,0,cardData1,heroCfg1);
            end
            if animNode2 then
                animNode2:setRhythm(1);
                game_anim:playSection(animNode2 , anim_label_name_cfg.daiji);
                animNode2:setAnchorPoint(ccp(0.5,0));
                parentNodeR:addChild(animNode2);
            end
        end
    end
  
    -- body
end

--截取cid
function game_godfield_battle_big.lua_string_split(self,str, split_char)
    local sub_str_tab = {};
    for mu_id in string.gmatch(str, "(%d+)_*") do
        table.insert(sub_str_tab, mu_id)
    end
    return sub_str_tab;
end

--[[--
    刷新
]]
function game_godfield_battle_big.refreshTableView(self)

end

--[[--
    刷新ui
]]
function game_godfield_battle_big.refreshUi(self,i)
    local tempSpriteFrame1,tempSpriteFrame2,tempSpriteFrame3
    if self.m_openType == "nightmare" or self.m_openType == "expedition"  then
        self:createPlayerIcon(i)
        tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_diyizhan2.png")
        tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_dierzhan2.png")
        tempSpriteFrame3 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_disanzhan2.png")
    else
        tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_diyizhan.png")
        tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_dierzhan.png")
        tempSpriteFrame3 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_disanzhan.png")
        self:createPlayerIcon(1)
    end
    self:getEmenyData(i)
    self:getMyData(i)
    self:battleAnim(i)
    
    
    if self.refreshUi_times == 1 then
        self.m_first_sp:setDisplayFrame(tempSpriteFrame1)
    elseif self.refreshUi_times == 2 then
        self.m_first_sp:setDisplayFrame(tempSpriteFrame2)
    elseif self.refreshUi_times == 3 then
        self.m_first_sp:setDisplayFrame(tempSpriteFrame3)
    end
    self.refreshUi_times = self.refreshUi_times+1

    --self:createHeroIcon(self.cid,self.leftIcon_node)
    --self:createHeroIcon(self.enemy_cid,self.rightIcon_node, self.m_itemData)
    
end
--[[--
    初始化
]]
function game_godfield_battle_big.init(self,t_params,t_params1)
    t_params = t_params or {};
    t_params1 = t_params1 or {};
    self.m_openType = t_params.opentype
    self.nightmareReward = t_params.nightmareReward or nil
    -- cclog2( self.nightmareReward,"init  self.nightmareReward === ")
    
    self.sort = t_params1.sort
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
    elseif tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end
    if t_params.data1 ~= nil and tolua.type(t_params.data1) == "util_json" then
        self.log_list = json.decode(t_params.data1:getNodeWithKey("data"):getFormatBuffer())
    elseif tolua.type(t_params.data1) == "table" then
        self.log_list = t_params.data1
    end
    -- cclog2(self.sort,"self.sortself.sort")
    self.my_flag = t_params.flag or nil;
    -- cclog2(self.my_flag,"self.my_flag")
    -- cclog2(self.m_tGameData,"self.m_tGameDataself.m_tGameDataself.m_tGameData")
    -- cclog2(self.log_list,"self.log_listself.log_list")
    self.pvp_reward = self.log_list["reward"]
    self.m_playNum = 1
    self.myVictory_num = 1;
    self.emenyVictory_num = 1;    
    self.enemy_cid = {}
    self.cid = {};
    self:getCid()
    self:getEnemyCid()
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_battle_big.create(self,t_params)
    local sort11 = sort
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self.m_battle_num = 1
    self.refreshUi_times = 1
    self:refreshUi(1);
    return scene;
end

return game_godfield_battle_big;