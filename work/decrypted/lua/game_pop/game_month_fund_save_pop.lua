--月初福利基金
local game_month_fund_save_pop={
	m_tGameData=nil,
    m_root_layer=nil,
    m_close_btn=nil,
    m_save_btn_1=nil,
    m_save_btn_2=nil,
    m_save_btn_3=nil,
    m_level_lab1=nil,
    m_level_lab2=nil,
    m_level_lab3=nil,
    m_leve1_coin_lab=nil,
    m_leve2_coin_lab=nil,
    m_leve3_coin_lab=nil,
    m_need_coin=nil,
    version=nil,
    coin=nil,
    level_buy=nil,
    active_tab=nil,

};

--[[--
    销毁ui
]]
function game_month_fund_save_pop.destroy(self)
    -- body
    cclog("-----------------game_month_fund_save_pop destroy-----------------");
    self.m_tGameData=nil;
    self.m_root_layer=nil;
    self.m_close_btn=nil;
    self.m_save_btn_1=nil;
    self.m_save_btn_2=nil;
    self.m_save_btn_3=nil;
    self.m_level_lab1=nil;
    self.m_level_lab2=nil;
    self.m_level_lab3=nil;
    self.m_leve1_coin_lab=nil;
    self.m_leve2_coin_lab=nil;
    self.m_leve3_coin_lab=nil;
    self.m_need_coin=nil;
    self.version=nil;
    self.coin=nil;
    self.level_buy=nil;
    self.active_tab=nil;
   
end


function game_month_fund_save_pop.back(self)
    
	   game_scene:removePopByName("game_month_fund_save_pop");

end


function game_month_fund_save_pop.createUi(self)
    local ccbNode=luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode=tolua.cast(target,"CCNode");
        local btnTag=tagNode:getTag();
        if btnTag==1 then
            self:back();
        elseif btnTag >=101 and btnTag<=103 then --存储
            --确认框
            local need_coin=0;
            if btnTag ==101 then
                need_coin =self.m_need_coin[1];
            elseif btnTag==102 then
                need_coin=self.m_need_coin[2];
            elseif btnTag==103 then
                need_coin=self.m_need_coin[3];
            end
            
            if self.level_buy ~="0" then
                game_util:addMoveTips({text = "Không thể lặp lại quỹ mua！"});

            else    
                if self.coin<need_coin then
                   game_util:addMoveTips({text = "Không đủ Xu!"});

                else
                    cclog2(tostring(self.active_tab[btnTag-100]),"tostring(self.active_tab[btnTag-100])")
                    local function responseMethod(tag, gameData)
                        game_util:closeAlertView();
                        local data = gameData:getNodeWithKey("data");
                        self:back();
                        game_scene:addPop("game_month_fund_pop",{gameData=gameData});
                        game_util:addMoveTips({text = "Đã nạp!"});

                    end
                    local t_params=
                    {
                    title=string_config.m_title_prompt,
                    okBtnCallBack=function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("month_foundation_activate"), http_request_method.GET, { id=tostring(self.active_tab[btnTag-100])},"month_foundation_activate")
                    end,
                    okBtnText=string_config.m_btn_sure,
                    cancelBtnText=string_config.m_btn_cancel,
                    text="Xác nhận tốn"..tostring(need_coin).."Xu mua Quỹ?",
                    onlyOneBtn=false,
                    touchPriority=GLOBAL_TOUCH_PRIORITY-13,

                    }

                    game_util:openAlertView(t_params);

                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_month_fund_save.ccbi");

   
    self.m_close_btn=ccbNode:controlButtonForName("close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-13);

    self.m_save_btn_1=ccbNode:controlButtonForName("save_btn_1");
    self.m_save_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-13);

    self.m_save_btn_2=ccbNode:controlButtonForName("save_btn_2");
    self.m_save_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-13);

    self.m_save_btn_3=ccbNode:controlButtonForName("save_btn_3");
    self.m_save_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY-13);

    
    self.m_level_lab1=ccbNode:labelTTFForName("level_lab_1");
    self.m_level_lab2=ccbNode:labelTTFForName("level_lab_2");
    self.m_level_lab3=ccbNode:labelTTFForName("level_lab_3");

    self.m_leve1_coin_lab=ccbNode:labelTTFForName("level1_coin_lab");
    self.m_leve2_coin_lab=ccbNode:labelTTFForName("level2_coin_lab");
    self.m_leve3_coin_lab=ccbNode:labelTTFForName("level3_coin_lab");

    if self.m_need_coin then
        self.m_leve1_coin_lab:setString(self.m_need_coin[1]);
        self.m_leve2_coin_lab:setString(self.m_need_coin[2]);
        self.m_leve3_coin_lab:setString(self.m_need_coin[3]);
    end

    local level1lab=self.m_tGameData.level1 or "1.2"  --todo
    self.m_level_lab1:setString(level1lab);
    local level2lab=self.m_tGameData.level2 or "1.5"
    self.m_level_lab2:setString(level2lab);
    local level3lab=self.m_tGameData.level3 or "2"
    self.m_level_lab3:setString(level3lab);

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode;


end




--刷新
function game_month_fund_save_pop.refreshUi(self)
    
 



end

function game_month_fund_save_pop.init(self,t_params)
	if t_params then
        self.m_tGameData = t_params.gameData;
        self.version=t_params.version
        self.coin=t_params.coin;
        self.level_buy=t_params.level_buy;
        self.active_tab=t_params.active_tab
    end
     self.m_need_coin={};
    local foundation_cfg = getConfig(game_config_field.month_foundation)  --获取配置
    local tempCount = foundation_cfg:getNodeCount();
     for i=1,tempCount do
        local itemCfg = foundation_cfg:getNodeAt(i - 1)
        if itemCfg then
            if itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.version then
                local need_coin = itemCfg:getNodeWithKey("need_coin"):toInt();
                table.insert(self.m_need_coin,need_coin)
            end
        end
    end
    table.sort(self.m_need_coin,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
 
end


function game_month_fund_save_pop.create(self,t_params)
	 self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi(true);
    return  m_popUi;
end
return game_month_fund_save_pop;