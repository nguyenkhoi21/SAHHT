---  神域界面

local game_godfield_main = {
    m_btn_tab = nil,
    m_label_tab = nil,
    m_gouami_btn = nil,
    m_chuanpiao_lab = nil,
    m_back_btn = nil,
    m_anim_node = nil,
    m_weekDay = nil,
    m_isenter = nil,
    m_payValue = nil,
     m_btn_zhenxing = nil,
    m_btn_duihuan = nil,
};
--[[--
    销毁
]]
function game_godfield_main.destroy(self)
    -- body
    cclog("-----------------game_godfield_main destroy-----------------");
    self.m_btn_tab = nil;
    self.m_label_tab = nil;
    self.m_gouami_btn = nil;
    self.m_chuanpiao_lab = nil;
    self.m_back_btn = nil;
    self.m_anim_node = nil;
    self.m_weekDay = nil;
    self.m_isenter = nil;
    self.m_payValue = nil;
    self.m_btn_zhenxing = nil;
    self.m_btn_duihuan = nil;

end
--[[--
    返回
]]
function game_godfield_main.back(self,type)
    if game_data:isViewShowByID (174) == true then
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_godfield_mainBig",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
    else
        local function endCallFunc()
           self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
    
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == -1 then --购买船票
            if self.m_isenter == false then
               
                local t_params = 
                        {
                            title = "Nhắc nhở",
                            okBtnCallBack = function(target,event)
                                require("game_ui.game_pop_up_box").close();
                                game_scene:setVisibleBroadcastNode(false);
                                cclog("maimaimai")
                               local function responseMethod( tag,gameData )
                                    -- cclog2(gameData,"gameData")
                                    game_util:addMoveTips({text = "Đã mua!"})
                                    --self:refreshData()
                                end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_buy_ship_ticket"), http_request_method.GET, params,"god_field_buy_ship_ticket")
                            end,   --可缺省
                            okBtnText = "Xác nhận",       --可缺省
                            text = "Tốn" .. self.m_payValue .. "Xu thần vực mua vé",      --可缺省
                            onlyOneBtn = true,          --可缺省
                        }
                        require("game_ui.game_pop_up_box").show(t_params);
                        retrunFlag = true;
            else
                game_util:addMoveTips({text = "Bạn đã mua vé, đợi đến thứ 7 vào nhé！"})
            end
        elseif btnTag == 101 then--阵型
           local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="game_godfield_main",});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
        
           
        elseif btnTag == 102 then--兑换
            local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_shop",{gameData = gameData,openType = "godfield_main"});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_exchange_index"), http_request_method.GET, params,"god_field_exchange_index")
         elseif btnTag == 167 or btnTag == 168 or btnTag == 169 then
            -- cclog2(btnTag,"btnTag === ")
            local activeCfg = getConfig(game_config_field.notice_active)
            local itemCfg = activeCfg:getNodeWithKey( tostring(btnTag) )
            itemCfg = json.decode(itemCfg:getFormatBuffer())
            local openMsg = itemCfg.word
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
        elseif btnTag == 202 or btnTag == 204 or btnTag == 206 then
            game_util:addMoveTips({text = "Không thể vào"});
        elseif btnTag == 201 then
            local function responseMethod( tag,gameData )
                -- body
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {};
                local is_formation = false
                is_formation = data.is_formation
                if is_formation == true then 
                    game_scene:enterGameUi("game_godfield_arean",{gameData = gameData})
                else
                    local function responseMethod(tag,gameData)
                    if gameData then
                        local first_time = true
                        game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="game_godfield_arean",first_time = first_time});
                    end
                end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
                end
            end
            
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")--周一到周五的界面
        elseif btnTag == 203 then --周六入口
            if  self.m_isenter == false then
                game_util:addMoveTips({text = "Bạn chưa mua vé thuyền！"})
            else
                local function responseMethod( tag,gameData )
                    game_scene:enterGameUi("game_godfield_arean",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")--周一到周五的界面
            end
        elseif btnTag == 205 then --周日战报
            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data");
                    data = json.decode(data:getFormatBuffer()) or {};
                     game_scene:enterGameUi("game_godfield_calendar_pop",{gameData = gameData});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_see_final_log"), http_request_method.GET, params,"god_field_see_final_log")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_main.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    local  sp = ccbNode:spriteForName("m_zhuyeban_sp")
    self.m_anim_node = ccbNode:nodeForName("anim_node")
    self.m_chuanpiao_lab = ccbNode:labelTTFForName("m_chuanpiao_lab")
    self.m_btn_zhenxing = ccbNode:controlButtonForName("m_btn_zhenxing")
    self.m_btn_duihuan = ccbNode:controlButtonForName("m_btn_duihuan")
    local m_xiangqing_btn = nil;
    local m_jinru2_btn = nil;
    local m_jinru_btn = nil;
    local m_zhuangtai_lab = nil;
    self.m_btn_tab = {}
    self.m_label_tab = {}
    for i=1,3 do
       m_xiangqing_btn = ccbNode:controlButtonForName("m_xiangqing_btn" .. i)
       m_jinru2_btn = ccbNode:controlButtonForName("m_jinru2_btn" .. i)
       m_jinru_btn = ccbNode:controlButtonForName("m_jinru_btn" .. i)
       m_zhuangtai_lab = ccbNode:labelTTFForName("m_zhuangtai_lab" .. i)
       self.m_btn_tab[i] = {m_xiangqing_btn = m_xiangqing_btn,m_jinru2_btn = m_jinru2_btn,m_jinru_btn = m_jinru_btn}
       self.m_label_tab[i] = {m_zhuangtai_lab = m_zhuangtai_lab}
    end
    local x = self.m_btn_tab[3].m_xiangqing_btn:getTag()
    -- cclog2(x,"x === ")
    -- sp:setScale(1)
    local anim = game_util:createEffectAnim("shenyubg",1,true)
    anim:setScale(2)
    anim:setAnchorPoint(ccp(0,0));
    self.m_anim_node:addChild(anim,10,10)


    return ccbNode;
end

--[[--
    刷新ui
]]
function game_godfield_main.refreshUi(self)
    self.m_chuanpiao_lab:setString(self.m_payValue)
    -- cclog2(self.m_weekDay,"m_weekDay =====  ")
    if self.m_tGameData.status == -1 or self.m_tGameData.status == 0 then
        for i=1,3 do
            self.m_btn_tab[i].m_jinru_btn:setVisible(false)
            self.m_label_tab[i].m_zhuangtai_lab:setString("Chưa mở")
            self.m_btn_tab[i].m_jinru2_btn:setVisible(true)
        end
    elseif self.m_weekDay == 1 then
        self.m_btn_tab[1].m_jinru_btn:setVisible(true)
        self.m_btn_tab[3].m_jinru_btn:setVisible(true)
        self.m_btn_tab[3].m_jinru2_btn:setVisible(false)
        self.m_btn_tab[1].m_jinru2_btn:setVisible(false)
        self.m_label_tab[1].m_zhuangtai_lab:setString("Đã mở")
        self.m_label_tab[1].m_zhuangtai_lab:setColor(ccc3(250,170,60))
    elseif self.m_weekDay == 2 then
        self.m_btn_tab[2].m_jinru_btn:setVisible(true)
        self.m_btn_tab[2].m_jinru2_btn:setVisible(false)
        self.m_btn_tab[3].m_jinru_btn:setVisible(true)
        self.m_btn_tab[3].m_jinru2_btn:setVisible(false)
        self.m_label_tab[2].m_zhuangtai_lab:setString("Đã mở")
        self.m_label_tab[2].m_zhuangtai_lab:setColor(ccc3(250,170,60))
    elseif self.m_weekDay == 3 then
        self.m_btn_tab[3].m_jinru_btn:setVisible(true)
        self.m_btn_tab[3].m_jinru2_btn:setVisible(false)
        self.m_label_tab[3].m_zhuangtai_lab:setString("Đã mở")
        self.m_label_tab[3].m_zhuangtai_lab:setColor(ccc3(250,170,60))
    end


end
--[[--
    初始化
]]
function game_godfield_main.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
       
        self.m_weekDay = self.m_tGameData.weekday or 1
        -- cclog2(self.m_tGameData.weekday,"self.m_tGameData.m_weekDay ===")
        self.m_isenter = self.m_tGameData.is_enter or false
    else
        self.m_tGameData = {};
    end
    local payCfg = getConfig(game_config_field.god_field_time);
    --cclog2(payCfg,"payCfg === ")
    payCfg = json.decode(payCfg:getFormatBuffer())
    --cclog2(payCfg["1"].cost,"payCfg === ")
    self.m_payValue = payCfg["1"].cost
    local temple_farmers = self.m_tGameData.temple_farmers
    game_data:setGodTempleCard(temple_farmers)
    -- body

end

--[[--
    创建ui入口并且初始化数据
]]
function game_godfield_main.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_main;