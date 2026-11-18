module(..., package.seeall)
require "shared.json"

--通用平台接口
function sendMessage(name, table, callback)
    -- body
    local temp = table or {}
    local param = json.encode(temp)
    cclog("...........sendMessage:...........name: %s", name,param)
    if callback ~= nil then
        local function response(str)
            -- cclog("-------- name:%s, respnse message:%s ---------", name , str)
            local data = json.decode(str, 0)
            callback(data)
        end
        if NDKHelper then
            NDKHelper:sendMessageToNative(name, param, response)
        else
            callback("none");
        end
    else
        if NDKHelper then
            NDKHelper:sendMessageToNative(name, param, nil)
        end
    end
end
--初始化過程
function init(callback)
    sendMessage("init", nil, callback)
end
--初始化
function sdkInit(callback)
   sendMessage("sdkInit", nil, callback) 
end
--登錄
function logIn(callback)
    -- body
    sendMessage("logIn", nil, callback)
end
-- 進入遊戲主頁面
function enterMainGame()
    sendMessage("enterMainGame", nil,nil)
end
--創建角色時調用
function sendInfocreaterRole(table)
    table = {create_zyz = "yes"}
   sendMessage("enterMainGame", table,nil)
end
--傳遞用戶信息
function sendInfoToPlatForm(table)
    -- body
    sendMessage("sendInfo", table, nil)
end
--傳遞登陸結果 
function logInResult(table)
    -- body
    sendMessage("logInResult", table, nil)
end
--註銷
function logOut(callback)
    -- body
    sendMessage("logOut", nil, callback)
end
--是否已登錄
function checkLogin(callback)
    sendMessage("isLogined", nil, callback)
end
--登錄後
function onLogin(username)
   local temp = {}
   temp.username = username
   sendMessage("onLogin",temp) 
end
--顯示浮動按鈕
function showFloatBar()
   sendMessage("showFloatBar",nil)  
end
--註銷後
function onLogout()
   sendMessage("onLogin",nil) 
end

-- 將要退出遊戲 
function platformExit(callback)
   sendMessage("platformExit", nil, callback) 
end

--退出遊戲   個別平台需要做特殊操作
function exitGame()
   sendMessage("exitGame",nil) 
end
--級別變後
function onUserLevelChanged(level)
   local temp = {}
   temp.level = level
   sendMessage("onUserLevelChanged",temp)
end
--開始支付
function onCharge(params,paymentType)
    local temp = {}
    temp.order = params.order
    temp.productId = params.productId
    temp.productPrice = params.productPrice
    temp.currencyType = params.currencyType
    temp.paymentType = paymentType
    sendMessage("onCharge",temp)
end
--設置服務器
function setGameServer(server)
    local temp = {}
    temp.server = server
    sendMessage("setGameServer",temp) 
end
--支付成功
function paySuccess(order)
    local temp = {}
    temp.order = order
    sendMessage("paySuccess",temp)
end
--購買
function buyProduct(item, callback)
    -- body
    --sendMessage("buyProduct", item, callback)
    local function sendNative(item2)
        sendMessage("buyProduct", item2, callback)
    end
    
    
    item._callback = sendNative
    
    local num = item.unit / 10000
    --cclog2("----num",num)
    local ticket = game_data:getUserStatusDataByKey("ticket")
    if ticket >= num then
        local function responseMethod(tag,gameData)
            local data = json.decode(gameData:getFormatBuffer()).data
            local params = {
                result = 0
            }
            callback(params)
            --game_util:addMoveTips({text = "购买成功"})
        end
        local t_params = 
            {
                onlyOneBtn = false,
                okBtnCallBack = function(target,event)
                    local random = math.randomseed(tostring(os.time()):reverse():sub(1, 6))
                    local randomNum = math.random(1,10000)--从里面随机取一个
                    local cpOrderId = item.orderid .. "_" .. randomNum
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("payment_use_ticket"), http_request_method.GET, {cpOrderId = cpOrderId},"payment_use_ticket")
                    game_util:closeAlertView();
                end,   --可缺省
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    game_scene:addPop("vnpay_pop",item)
                end,
                --okBtnText = "使用",       --可缺省
                --cancelBtnText = "不使用",
                text = "bạn có thể sử dụng Phiếu giảm giá để mua hàng trực tiếp. Nếu bạn chọn không sử dụng, bạn sẽ vào trang thanh toán để mua hàng.",      --可缺省
                closeFlag = true,
            }
        game_util:openAlertView(t_params);
    else
        game_scene:addPop("vnpay_pop",item)
    end

end
--[[
    传入角色名等
]]
function sendRoleInfo(table)
    cclog2(table)
    local temp = table
    sendMessage("sendRoleInfo",temp) 
end
--获得创建的角色名
function getUserName(name)
   local temp = {}
   temp.name = name
   sendMessage("getUserName",temp)
end
--用於bi統計
function biRecord(event, table)
    -- body
    local temp = {}
    temp.event = event
    temp.data = table or {}

    sendMessage("biRecord", temp, nil)  
end

--獲取當前接入平台名稱
function platformName(callback)
    -- body
    local temp = {}
    sendMessage("platformName", temp, callback)
end

function needShowSDKBtn(callback)
    -- body
    local temp = {}
    sendMessage("needShowSDKBtn", temp, callback)
end

--進入個人中心
function enterUserCenter(table,callback)
    -- body
    local temp = table or {}
    sendMessage("enterUserCenter", temp, callback)
end

function listenBroadCast(name, callback)
    -- body
    if name == nil then
        return
    end
    if NDKHelper then
        NDKHelper:listenNativeMessage(name, callback)
    end
end

--[[
    设置 ios 目录不需要备份
]]
function addSkipBackupAttributeToItemAtURLs( params, callback )
    params = params or {}
    local writablePath = CCFileUtils:sharedFileUtils():getWritablePath()
    -- cclog2("writablePath====",writablePath)
    -- os.mkdir(writablePath .. "fb/")--创建fb 头像目录
    local paths = {}
    paths[#paths + 1] = writablePath .. "config"
    paths[#paths + 1] = writablePath .. "Resources"
    paths[#paths + 1] = writablePath .. "lua"
    paths[#paths + 1] = writablePath .. "sound"
    params.paths = paths
    local callback = function ( ... )
        
    end
    sendMessage( "addSkipBackupAttributeToItemAtURLs", params, callback  )
end

function isLoginChat(table, callback)
    local temp = table or {}
    sendMessage("isLoginChat", temp, callback)
end

function loginChat(table, callback)
    local temp = table or {}
    sendMessage("loginChat", temp, callback)
end

function sendMsg(table, callback)
    local temp = table or {}
    sendMessage("sendMsg", temp, callback)
end

function sendRoomMsg(table)
    local temp = table or {}
    sendMessage("sendRoomMsg", temp, nil)
end

function enterChatRoom(table, callback)
    local temp = table or {}
    sendMessage("enterChatRoom", temp, callback)
end

function exitCharRoom(table)
    local temp = table or {}
    sendMessage("exitCharRoom", temp, nil)
end

function queryMsg(table, callback)
    local temp = table or {}
    sendMessage("queryMsg", temp, callback)
end

function queryTeamMsg(table, callback)
    local temp = table or {}
    sendMessage("queryTeamMsg", temp, callback)
end

function queryRoomMsg(table,callback)
    local temp = table or {}
    sendMessage("queryRoomMsg", temp, callback)
end

function addToBlackList(table,callback)  --
    local temp = table or {}
    sendMessage("addToBlackList", temp, callback)
end

function removeFromBlackList(table,callback)  --
    local temp = table or {}
    sendMessage("removeFromBlackList", temp, callback)
end