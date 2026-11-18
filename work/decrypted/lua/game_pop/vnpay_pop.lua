--- 帳號登陸
local md5 = require("shared.md5")
local vnpay_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_item = nil,
    m_callBackFunc = nil,
};
--[[--
    銷毀
]]
function vnpay_pop.destroy(self)
    -- body
    cclog("-----------------account_login_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_item = nil;
    self.m_callBackFunc = nil;
end
--[[--
    返回
]]
function vnpay_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("vnpay_pop");
end
--[[--
    讀取ccbi創建ui
]]
function vnpay_pop.createUi(self)
    local ccbNode = luaCCBNode:create();

    local appKey="10000389"--10000389
    local secret = "07DD31B233338EC2018FBD461819E8F5"--07DD31B233338EC2018FBD461819E8F5
    local appGoodsKey="GSK731"--GSK787

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--關閉
            self:back();
        elseif btnTag == 2 then--註冊
            local function responseMethod(tag,response)
                local buffer = response:getResponseDataBuffer();
                local gameData = util_json:new(buffer);
                local data = json.decode(gameData:getFormatBuffer())
                cclog2(data,"---data")
                if data and data.url then 
                    local data = {
                        upayurl = data.url
                    }
                    self.m_callBackFunc(data)
                end
                require("game_ui.game_loading").close()
                self:back()
            end
            local function payFunc()
                local userName = tostring(util.url_encode(self.m_item.roleName))
                local issuerID = tostring(util.url_encode(self.m_item.description))
                local txnAmount = self.m_item.unit
                local url = "http://pay.upay365.com/api/onlineBank/megabankDeposite?type_id=11&cpOrderId=" .. self.m_item.orderid .. "&txnAmount="..txnAmount.."&appKey="..appKey.."&goodsKey="..appGoodsKey.."&userName=" ..self.m_item.userId.."&issuerID="..issuerID
                --cclog2(url,"--url")
                local httpReq = CCHttpRequest:new()
                httpReq:setUrl(url)
                httpReq:registerScriptTapHandler(responseMethod)
                httpReq:setRequestType(0)
                httpReq:setTag("upay")
                CCHttpClient:getInstance():send(httpReq)
                httpReq:release()
                require("game_ui.game_loading").show();
            end
            
            local t_params = 
            {
                title = "Nhắc nhở",
                okBtnCallBack = function(target,event)
                    cclog("rightBtnCallBack");
                    require("game_ui.game_pop_up_box").close(); 
                    payFunc()
                    
                end,   --可缺省
                okBtnText = "ĐI ĐẾN",       --可缺省
                text = "Sau khi nhảy trang web, vui lòng thanh toán trực tiếp mã QRcode trên trang, nếu bạn chuyển tiếp trang hoặc lỡ làm mới lại mã QR, vui lòng thoát nó ra và thực hiện tạo lại một hoá đơn khác!",      --可缺省
                onlyOneBtn = true,          --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);
        elseif btnTag == 3 then--登錄
            local function responseMethod(tag,response)
                local buffer = response:getResponseDataBuffer();
                local gameData = util_json:new(buffer);
                local data = json.decode(gameData:getFormatBuffer())
                cclog2(data,"---data")
                if data and data.url then 
                    local data = {
                        upayurl = data.url
                    }
                    self.m_callBackFunc(data)
                end
            
                require("game_ui.game_loading").close()
                self:back()
            end
            local payFunc = function()
                local userName = tostring(util.url_encode(self.m_item.roleName))
                local issuerID = tostring(util.url_encode(self.m_item.description))
                local txnAmount = self.m_item.unit
                local url = "http://pay.upay365.com/api/onlineBank/megabankDeposite?type_id=12&cpOrderId=" .. self.m_item.orderid .. "&txnAmount="..txnAmount.."&appKey="..appKey.."&goodsKey="..appGoodsKey.."&userName=" ..self.m_item.userId.."&issuerID="..issuerID
                local httpReq = CCHttpRequest:new()
                httpReq:setUrl(url)
                httpReq:registerScriptTapHandler(responseMethod)
                httpReq:setRequestType(0)
                httpReq:setTag("upay")
                CCHttpClient:getInstance():send(httpReq)
                httpReq:release()
                require("game_ui.game_loading").show();
            end

            local t_params = 
            {
                title = "Nhắc nhở",
                okBtnCallBack = function(target,event)
                    cclog("rightBtnCallBack");
                    require("game_ui.game_pop_up_box").close(); 
                    payFunc()
                    
                end,   --可缺省
                okBtnText = "ĐI ĐẾN",       --可缺省
                text = "Sau khi nhảy trang web, vui lòng thanh toán trực tiếp mã QRcode trên trang, nếu bạn chuyển tiếp trang hoặc lỡ làm mới lại mã QR, vui lòng thoát nó ra và thực hiện tạo lại một hoá đơn khác!",      --可缺省
                onlyOneBtn = true,          --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);
        elseif btnTag == 4 then--登錄
            local function responseMethod(tag,response)
                local buffer = response:getResponseDataBuffer();
                local gameData = util_json:new(buffer);
                local data = json.decode(gameData:getFormatBuffer())
                cclog2(data,"---data")
                if data and data.url then 
                    local data = {
                        upayurl = data.url
                    }
                    self.m_callBackFunc(data)
                end
                require("game_ui.game_loading").close()
                self:back()
            end

            local payFunc = function()
                local userName = tostring(util.url_encode(self.m_item.roleName))
                local issuerID = tostring(util.url_encode(self.m_item.description))
                local txnAmount = self.m_item.unit
                local url = "http://pay.upay365.com/api/onlineBank/megabankDeposite?type_id=10&cpOrderId=" .. self.m_item.orderid .. "&txnAmount="..txnAmount.."&appKey="..appKey.."&goodsKey="..appGoodsKey.."&userName=" ..self.m_item.userId.."&issuerID="..issuerID
                cclog2(url,"--url")
                local httpReq = CCHttpRequest:new()
                httpReq:setUrl(url)
                httpReq:registerScriptTapHandler(responseMethod)
                httpReq:setRequestType(0)
                httpReq:setTag("upay")
                CCHttpClient:getInstance():send(httpReq)
                httpReq:release()
                require("game_ui.game_loading").show();
            end
            local t_params = 
            {
                title = "Nhắc nhở",
                okBtnCallBack = function(target,event)
                    cclog("rightBtnCallBack");
                    require("game_ui.game_pop_up_box").close(); 
                    payFunc()
                    
                end,   --可缺省
                okBtnText = "ĐI ĐẾN",       --可缺省
                text = "Sau khi nhảy trang web, vui lòng thanh toán trực tiếp mã QRcode trên trang, nếu bạn chuyển tiếp trang hoặc lỡ làm mới lại mã QR, vui lòng thoát nó ra và thực hiện tạo lại một hoá đơn khác!",      --可缺省
                onlyOneBtn = true,          --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);
        elseif btnTag == 6 then--登錄
            local function responseMethod(tag,response)
                local buffer = response:getResponseDataBuffer();
                local gameData = util_json:new(buffer);
                local data = json.decode(gameData:getFormatBuffer())
                cclog2(data,"---data")
                if data and data.responsecode == "00"then 
                    local data = {
                        upayurl = data.url
                    }
                    self.m_callBackFunc(data)
                end
                require("game_ui.game_loading").close()
                self:back()
            end

            local payFunc = function()
                local userName = tostring(util.url_encode(self.m_item.roleName))
                local issuerID = tostring(util.url_encode(self.m_item.description))
                local txnAmount = self.m_item.unit
                local url = "http://pay.upay365.com/api/onlineBank/megabankDeposite?type_id=15&cpOrderId=" .. self.m_item.orderid .. "&txnAmount="..txnAmount.."&appKey="..appKey.."&goodsKey="..appGoodsKey.."&userName=" ..self.m_item.userId.."&issuerID="..issuerID
                cclog2(url,"--url")
                local httpReq = CCHttpRequest:new()
                httpReq:setUrl(url)
                httpReq:registerScriptTapHandler(responseMethod)
                httpReq:setRequestType(0)
                httpReq:setTag("upay")
                CCHttpClient:getInstance():send(httpReq)
                httpReq:release()
                require("game_ui.game_loading").show();
            end
            local t_params = 
            {
                title = "Nhắc nhở",
                okBtnCallBack = function(target,event)
                    cclog("rightBtnCallBack");
                    require("game_ui.game_pop_up_box").close(); 
                    payFunc()
                    
                end,   --可缺省
                okBtnText = "ĐI ĐẾN",       --可缺省
                text = "Sau khi nhảy trang web, vui lòng thanh toán trực tiếp mã QRcode trên trang, nếu bạn chuyển tiếp trang hoặc lỡ làm mới lại mã QR, vui lòng thoát nó ra và thực hiện tạo lại một hoá đơn khác!",      --可缺省
                onlyOneBtn = true,          --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);
        elseif btnTag == 5 then--已經充過了
            local updataUrl = "https://vn.superhero.hi365.com/feedback/" 
            util_system:openUrlOutside(updataUrl);
        elseif btnTag == 10 then--充值卡
            local vendor = "vietnamVMS"
            local m = md5.new()
            m:update(appKey..appGoodsKey..self.m_item.orderid.."vietnam"..secret)
            local hash = md5.tohex(m:finish())
            
            local url = "https://pay.upay365.com/toDiffCountry/webCashCard?appKey="..appKey.."&appGoodsKey="..appGoodsKey.."&cpOrderId=" .. self.m_item.orderid ..  "&chKey=1&uid="..self.m_item.userId.."&vendor="..vendor.."&equipmentType=2&countryName=vietnam&cpInquiryUrl=&hash="..hash
            cclog2(url,"--url")
            util_system:openUrlOutside(url);
        elseif btnTag == 11 then--充值卡
            local vendor = "vietnamVNP"
            local m = md5.new()
            m:update(appKey..appGoodsKey..self.m_item.orderid.."vietnam"..secret)
            local hash = md5.tohex(m:finish())
            
            local url = "https://pay.upay365.com/toDiffCountry/webCashCard?appKey="..appKey.."&appGoodsKey="..appGoodsKey.."&cpOrderId=" .. self.m_item.orderid ..  "&chKey=1&uid="..self.m_item.userId.."&vendor="..vendor.."&equipmentType=2&countryName=vietnam&cpInquiryUrl=&hash="..hash
            cclog2(url,"--url")
            util_system:openUrlOutside(url);
        elseif btnTag == 12 then--充值卡
            local vendor = "vietnamVTT"
            local m = md5.new()
            m:update(appKey..appGoodsKey..self.m_item.orderid.."vietnam"..secret)
            local hash = md5.tohex(m:finish())
            
            local url = "https://pay.upay365.com/toDiffCountry/webCashCard?appKey="..appKey.."&appGoodsKey="..appGoodsKey.."&cpOrderId=" .. self.m_item.orderid ..  "&chKey=1&uid="..self.m_item.userId.."&vendor="..vendor.."&equipmentType=2&countryName=vietnam&cpInquiryUrl=&hash="..hash
            cclog2(url,"--url")
            util_system:openUrlOutside(url);
        elseif btnTag == 13 then--充值卡
            local vendor = "vietnamZING"
            local m = md5.new()
            m:update(appKey..appGoodsKey..self.m_item.orderid.."vietnam"..secret)
            local hash = md5.tohex(m:finish())
            
            local url = "https://pay.upay365.com/toDiffCountry/webCashCard?appKey="..appKey.."&appGoodsKey="..appGoodsKey.."&cpOrderId=" .. self.m_item.orderid ..  "&chKey=1&uid="..self.m_item.userId.."&vendor="..vendor.."&equipmentType=2&countryName=vietnam&cpInquiryUrl=&hash="..hash
            cclog2(url,"--url")
            util_system:openUrlOutside(url);
        elseif btnTag == 14 then--充值卡
            local vendor = "vietnamFPT"
            local m = md5.new()
            m:update(appKey..appGoodsKey..self.m_item.orderid.."vietnam"..secret)
            local hash = md5.tohex(m:finish())
            
            local url = "https://pay.upay365.com/toDiffCountry/webCashCard?appKey="..appKey.."&appGoodsKey="..appGoodsKey.."&cpOrderId=" .. self.m_item.orderid ..  "&chKey=1&uid="..self.m_item.userId.."&vendor="..vendor.."&equipmentType=2&countryName=vietnam&cpInquiryUrl=&hash="..hash
            cclog2(url,"--url")
            util_system:openUrlOutside(url);
        end

    end
    local a = {"vietnamVMS","vietnamVNP","vietnamVTT","vietnamZING","vietnamFPT"}
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_vnpay_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_momo_btn = ccbNode:controlButtonForName("m_momo_btn")
    local m_banklng_btn = ccbNode:controlButtonForName("m_banklng_btn")
    local m_zalo_btn = ccbNode:controlButtonForName("m_zalo_btn")
    local m_tip_btn = ccbNode:controlButtonForName("m_tip_btn")
    local m_viettel_btn = ccbNode:controlButtonForName("m_viettel_btn")

    local m_vietnamVMS_btn = ccbNode:controlButtonForName("m_vietnamVMS_btn")
    local m_vietnamVNP_btn = ccbNode:controlButtonForName("m_vietnamVNP_btn")
    local m_vietnamVTT_btn = ccbNode:controlButtonForName("m_vietnamVTT_btn")
    local m_vietnamZING_btn = ccbNode:controlButtonForName("m_vietnamZING_btn")
    local m_vietnamFPT_btn = ccbNode:controlButtonForName("m_vietnamFPT_btn")

    
    if self.m_item.unit < 50000 then
        m_banklng_btn:setEnabled(false);
        m_banklng_btn:setColor(ccc3(127,127,127))
    end

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    m_momo_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    m_banklng_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    m_zalo_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    m_tip_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    m_viettel_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);

    -- m_vietnamVMS_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    -- m_vietnamVNP_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    -- m_vietnamVTT_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    -- m_vietnamZING_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    -- m_vietnamFPT_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);

    -- local point_card = self.m_item.point_card;
    -- local btns = {m_vietnamVMS_btn,m_vietnamVNP_btn,m_vietnamVTT_btn,m_vietnamZING_btn,m_vietnamFPT_btn}
    -- cclog2(point_card,"point_card--")
    -- for k,v in ipairs(btns) do
    --     btns[k]:setEnabled(false);
    --     btns[k]:setColor(ccc3(127,127,127))
    -- end
    -- for k,v in ipairs(point_card) do
    --     cclog(v)
    --     cclog(k)
    --     btns[v]:setEnabled(true);
    --     btns[v]:setColor(ccc3(255,255,255))
    -- end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-100,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end



--[[--
    刷新ui
]]
function vnpay_pop.refreshUi(self)

end

--[[--
    初始化
]]
function vnpay_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_callBackFunc = t_params._callback
    self.m_item = t_params
    -- body
end

--[[--
    創建ui入口並初始化數據
]]
function vnpay_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return vnpay_pop;
