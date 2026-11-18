-- 某些地方用到前往功能 
local M = {}

qucik_entrys = {}

qucik_entrys.trainfinish = 
function ()
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_school_new",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_open"), http_request_method.GET, nil,"school_open")
end









function M.getQuickEntryFun( name, isNet, startFun, endFun )
    startFun = startFun or function ()    end
    endFun = endFun or function ()    end

end



function game_do_something_pop.getOpenButtonInfoByID(self, bid , spriteName, chapterID)
    
    local gtactivity = function(itemIndex , chapterID)
        self:goToActivity(itemIndex, chapterID)
    end



    local game_button_ids = {}
    -- 卡牌分解
    -- 裝備精煉
    -- 裝備分解



    game_button_ids["105"] = { name = "EXP Thần Thú" , resFramesName = "ccbResources/activity.plist", spriteName = "button_active_exp", goToCallFun = gtactivity, chapterID = 80};    -- 馬上有經驗   17級開啟   不引導
    game_button_ids["106"] = { name = "Cuộc chiến giành tài nguyên", resFramesName = "ccbResources/activity.plist",spriteName = "button_active_resource", goToCallFun = gtactivity, chapterID = 1 };-- 資源爭奪戰   12級開啟   不引導
    game_button_ids["107"] = { name = "Thử Thách Sinh Tồn", resFramesName = "ccbResources/activity.plist",spriteName = "button_active_live",  goToCallFun = gtactivity , itemIndex = 10 };-- 生存大考驗   20級開啟   不引導
    game_button_ids["108"] = { name = "Khiêu chiến mỗi ngày" ,  resFramesName = "ccbResources/activity.plist", spriteName = spriteName, goToCallFun = gtactivity, chapterID = chapterID};-- 每日挑戰   15級開啟   不引導
    game_button_ids["109"] = { name = "Khiêu chiến cực hạn" ,  resFramesName = "ccbResources/activity.plist", spriteName = spriteName , goToCallFun = gtactivity, chapterID = chapterID};-- 極限挑戰 15級開啟   不引導
    game_button_ids["200"] = { name = "Đấu trường",  spriteName = "mbutton_m_fight" , goToCallFun = function ()
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index"); end };-- 競技場 完成 1-4 花園城市 後開啟 第四關強制
    game_button_ids["307"] = { name = "Cửa hàng siêu năng ", spriteName = "mbutton_5_3",  goToCallFun = function ()
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_card_split_shop",{gameData = gameData,openType = "game_function_pop"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")  
                           
        end};-- 超能商店    16級開啟   說一句話
    game_button_ids["501"] = { name = "Huấn luyện đồng đội", spriteName = "mbutton_2_1", goToCallFun = function ()
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_school_new",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_open"), http_request_method.GET, nil,"school_open")
    end };-- 夥伴訓練    5級開啟    說一句話

    game_button_ids["502"] = { name = "Tiến hóa đồng đội", spriteName = "mbutton_2_3", goToCallFun = function ()  game_scene:enterGameUi("skills_inheritance_scene",{gameData = nil}); end };-- 夥伴進階    完成 1-4 花園城市 後開啟 收復固定建築（綠箭俠那個）
    game_button_ids["503"] = { name = "Nâng cấp kĩ năng", spriteName = "mbutton_2_2", goToCallFun = function ()  game_scene:enterGameUi("skills_strengthen_scene",{gameData = nil}); end};-- 技能升級    完成 1-3 神秘名勝 後開啟 完成第三關強制
    game_button_ids["506"] = { name = "Kế thừa đồng đội", spriteName = "mbutton_5_5", goToCallFun = function ()  game_scene:enterGameUi("game_hero_inherit"); end };-- 夥伴傳承    12級開啟   不引導
    game_button_ids["507"] = { name = "Phân giải đồng đội", spriteName = "mbutton_5_4", goToCallFun = function ()  game_scene:enterGameUi("game_card_split"); end};-- 夥伴分解    16級開啟   說一句話
    game_button_ids["509"] = { name = "Cải tạo thuộc tính", spriteName = "mbutton_2_4", goToCallFun = function ()  game_scene:enterGameUi("game_hero_culture_scene",{gameData = gameData}); end };-- 屬性改造(連同戰敗)  13級開啟   進入之後引導
    game_button_ids["601"] = { name = "Xem trang bị", spriteName = "mbutton_3_4", goToCallFun = function ()  game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "game_function_pop"}); end };-- 查看裝備    完成 1-2 廢區城市 後開啟 不引導
    game_button_ids["602"] = { name = "Cường hóa trang bị", spriteName = "mbutton_3_1", goToCallFun = function ()  game_scene:enterGameUi("equipment_strengthen",{gameData = nil}) end };-- 裝備強化(連同戰敗)  完成 1-2 廢區城市 後開啟 完成第二關強制
    game_button_ids["603"] = { name = "Tiến hóa trang bị", spriteName = "mbutton_3_2", goToCallFun = function ()  game_scene:enterGameUi("equip_evolution",{gameData = nil}); end };-- 裝備進階    14級開啟   不引導
    game_button_ids["605"] = { name = "Kĩ năng anh hùng", spriteName = "mbutton_6_1", goToCallFun = function ()  
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("skills_practice_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_open"), http_request_method.GET, nil,"leader_skill_open")
     end  };-- 英雄技能    18級開啟   說一句話
    game_button_ids["700"] = { name = "Liên minh", spriteName = "mbutton_4_2", goToCallFun = function ()
            game_scene:setVisibleBroadcastNode(false);
            local association_id = game_data:getUserStatusDataByKey("association_id");
            if association_id == 0 then
                require("like_oo.oo_controlBase"):openView("guild_join");
            else
                require("like_oo.oo_controlBase"):openView("guild");
            end
    end};-- 公會  10級開啟   不引導
    game_button_ids["800"] = { name = "Ải Tinh Anh" , resFramesName = "ccbResources/ui_map_world_res.plist", spriteName = "sjdt_elite_levels_btn" , goToCallFun = function ()        
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("map_world_scene",{gameData = gameData, chapterSwitchTo = "hard", assign_chapter = 1});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    end};-- 精英關卡    完成 1-4 花園城市 後開啟 不引導
    game_button_ids["110"] = { name = "Đất vô chủ", resFramesName = "ccbResources/activity.plist", spriteName = "button_active_middle",  goToCallFun = gtactivity, itemIndex = 5  };-- 無主之地    10級開啟   不引導
        

    game_button_ids["606"] = { name = "Năng lực thống soái", spriteName = "mbutton_tsnl", goToCallFun = function ()  
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_ability_commander",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_index"), http_request_method.GET, nil,"commander_index") 
    end };-- 裝備拆分 
    game_button_ids["607"] = { name = "Tách trang bị", spriteName = "mbutton_2_split", goToCallFun = function ()  game_scene:enterGameUi("ui_equip_split"); end };-- 裝備拆分 
    game_button_ids["608"] = { name = "Tinh luyện trang bị", spriteName = "mbutton_2_st", goToCallFun = function ()  game_scene:enterGameUi("game_equip_refining"); end };-- 裝備精煉



    game_button_ids["btn122"] = { name = "伙伴融合", btnId = 1000001, resFramesName = "ccbResources/new_main_add_res.plist",  spriteName = "m_button_melting.png", goToCallFun = function ()
            game_scene:enterGameUi("game_card_melting",{})
    end};


    return game_button_ids[tostring(bid)]
end









return M