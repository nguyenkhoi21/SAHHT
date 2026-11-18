local game_god_escort_helper = {}

--[[
    翻译
]]
game_god_escort_helper.txt = {
    god_escort_txt_1 = "Đặt Cược", -- 我的赌注"
    god_escort_txt_2 = "Tin giải đấu tinh tế", -- 星 际 赛 事"
    god_escort_txt_3 = "00:00:00",
    god_escort_txt_4 = "Xem trước thưởng hàng tuần", -- 每周奖励预览:"
    god_escort_txt_5 = "Hoàn thành nhiệm vụ nhận tích điểm để giành lấy phần thưởng tương ứng", -- 完成任务获得积分赢取相应奖励"
    god_escort_txt_6 = "Năng lượng hiện tại", -- 当前能量:"
    god_escort_txt_7 = "Trạng thái hôm nay", -- 今日状态"
    god_escort_txt_8 = "Tỉ lệ cược %s", -- 赔率%s"
    god_escort_txt_9 = "Kho thưởng", -- 远航奖池"
    god_escort_txt_10 = "XH", -- 远航排名"
    god_escort_txt_11 = "Thưởng khoang", -- 量子仓奖励"
    god_escort_txt_12 = "Mốc", -- 光年里程碑"
    god_escort_txt_13 = "",
    god_escort_txt_14 = "Cơ sở", -- 基础数量"
    god_escort_txt_15 = "Bổ sung", -- 补给数量"
    god_escort_txt_16 = "Tổng cá nh", -- 个人总量"
    god_escort_txt_17 = "Giới thiệu", -- 规则说明"
    god_escort_txt_18 = "Hoàn thành thưởng Về Đích, XH dựa theo khoảng cách cuối cùng; chưa về đích không có thưởng", -- 完成冲线奖励,且最终距离长短决定排名;未冲线无奖励"
    god_escort_txt_19 = "Người giúp đỡ phi thuyền XH nhất khi viễn chinh sẽ được thưởng", -- 远航排名第一飞船的协助者可领取该奖励"
    god_escort_txt_20 = "Điểm thành tựu sẽ làm mới vào 00:00 thứ 2 hằng tuần", -- 成就积分每周一00：00刷新"
    god_escort_txt_21 = "%s điểm", -- %s积分"
    god_escort_txt_22 = "Thưởng:", -- 奖励:"
    god_escort_txt_23 = "Điểm", -- 积分"
    god_escort_txt_24 = "Thời gian còn lại của giai đoạn hiện tại:", -- 当前阶段剩余时间:"
    god_escort_txt_25 = "Đổi", -- 兑换"
    god_escort_txt_26 = "Năng lượng bay", -- 远航能量"
    god_escort_txt_27 = "Lần chuyển hóa này tốn %s %s, tổng cộng nhận được %s năng lượng, xác nhận chuyển hóa?", -- 本次转化消耗%s个%s,总计获得%s能量,确定转化吗?"
    god_escort_txt_28 = "Chuyển hóa thành công", -- 转化成功"
    god_escort_txt_29 = "Bạn vẫn chưa đạt đến mức cược nhỏ nhất", -- 你尚未能达到最小投注量"
    god_escort_txt_30 = "Đã đạt đến mức cược nhỏ nhất", -- 已达到最小投注量"
    god_escort_txt_31 = "Đã đạt đến mức cược lớn nhất", -- 已达到最大投注量"
    god_escort_txt_32 = "Cược:", -- 投入: "
    god_escort_txt_33 = "Lợi tức:", -- 收益: "
    god_escort_txt_34 = "Đặt cược thành công", -- 投入成功"
    god_escort_txt_35 = "Phi thuyền đang ở tinh hệ:", -- 飞船所在星系: "
    god_escort_txt_36 = "Tổng hành trình: %s năm ánh sáng", -- 累计航行: %s光年"
    god_escort_txt_37 = "Lợi tức phụ: %s%%", -- 额外收益: %s%%"
    god_escort_txt_38 = "Tốc độ đầu: %s năm ánh sáng/s", -- 初始秒速: %s光年/s"
    god_escort_txt_39 = "Gia tốc: %s năm ánh sáng/s", -- 加速秒速: %s光年/s"
    god_escort_txt_40 = "Trợ Giúp của tôi", -- 我的助力"
    god_escort_txt_41 = "Trợ giúp phi thuyền đăng quang sẽ được nhận thưởng thêm", -- 助力飞船登顶可获得额外奖励"
    god_escort_txt_42 = "Tàu vũ trụ", -- 穿梭器"
    god_escort_txt_43 = "Khoang phi thuyền", -- 量子仓"
    god_escort_txt_44 = "Năng nguyên Aether", -- 以太能源"
    god_escort_txt_45 = "LY", -- 光年"
    god_escort_txt_46 = "Trạng thái của tôi", -- 我的状态"
    god_escort_txt_47 = "So sánh số lượng hai bên cho ra kết quả cuối cùng", -- 最终结果由对应较量的数量决定"
    god_escort_txt_48 = "Tăng cường", -- 加强"
    god_escort_txt_49 = "Tường nhân tạo", -- 人造墙"
    god_escort_txt_50 = "Khe nứt nhỏ", -- 小裂缝"
    god_escort_txt_51 = "Thuốc đóng băng", -- 永凝剂"
    god_escort_txt_52_1 = "Trợ Giúp tốc độ cơ sở thành công, nhận được tốc độ cơ sở", -- 基础速度助威成功, 获得基础速度"
    god_escort_txt_52_2 = "Trợ giúp gia tốc thành công, nhận được gia tốc", -- 加速度助威成功, 获得加速度"
    god_escort_txt_52_3 = "Trợ giúp lợi tức phụ thành công, nhận được lợi tức phụ", -- 额外收益助威成功，获得额外收益"
    god_escort_txt_52_4 = "Quấy rối tốc độ cơ sở thành công, giảm tốc độ cơ sở", -- 基础速度干扰成功, 减少基础速度"
    god_escort_txt_52_5 = "Quấy rối gia tốc thành công, giảm gia tốc", -- 加速度干扰成功, 减少加速度"
    god_escort_txt_52_6 = "Quấy rối lợi tức phụ thành công, giảm lợi tức phụ", -- 额外收益干扰成功，减少额外收益"
    god_escort_txt_53 = "Không đủ đạo cụ Trợ Giúp, hãy vào Cửa Hàng mua thêm", -- 助威道具不足，请前往商店购买"
    god_escort_txt_54 = "Không đủ đạo cụ Quấy Rối, hãy vào Cửa Hàng mua thêm", -- 干扰道具不足，请前往商店购买"
    god_escort_txt_55 = "Kho thưởng", -- 奖池"
    god_escort_txt_56 = "Thêm", -- 额外"
    god_escort_txt_57 = "Cá nhân", -- 个人"
    god_escort_txt_58 = "Không đủ điểm", -- 积分不足"
    god_escort_txt_59 = "Bạn đã nhận thưởng", -- 你已领奖"
    god_escort_txt_60 = "Nhận", -- 领取"
    god_escort_txt_61 = "Đã nhận", -- 已领取"
    god_escort_txt_62 = "Chưa hoàn thành", -- 未完成"
    god_escort_txt_63 = "Chỉ có giai đoạn chuẩn bị mới được Đặt Cược", -- 只有准备阶段可以投注"
    god_escort_txt_64 = "Mua thành công", -- 购买成功"
    god_escort_txt_65 = "Năng lượng đơn:", -- 单体能量: "
    god_escort_txt_66 = "Ước tính:", -- 预计转化: "
    god_escort_txt_67 = "Tiêu hao Khoang phi thuyền", -- 消耗量子仓"
    god_escort_txt_68 = "Lợi tức phụ %d%%(%s/%s)", -- 额外收益%d%%(%s/%s)"
    god_escort_txt_69 = "Chưa đạt đến", -- 尚未达成"
    god_escort_txt_70 = "Đã gửi thư", -- 已发放邮箱"
    god_escort_txt_71 = "Tổng cự li", -- 总距离"
    god_escort_txt_72 = "Vị thứ", -- 名次"
    god_escort_txt_73 = "% thưởng cơ sở * tỉ lệ cá nhân", -- %基础奖励*个人占比"
    god_escort_txt_74 = "Bạn đã đặt cược cho phi thuyền trong vũ trụ hiện tại", -- 当前宇宙您已有飞船被下注"
    god_escort_txt_75 = "Bạn chưa đặt cược cho phi thuyền trong vũ trụ hiện tại", -- 当前宇宙您未下注飞船"
    god_escort_txt_76 = "Bạn chưa đặt cược cho phi thuyền hiện tại", -- 您未下注当前飞船"
    god_escort_txt_77 = "Bạn không thể sử dụng đạo cụ này cho phi thuyền đã đặt cược", -- 您不能对您下注飞船使用该道具"
    god_escort_txt_78 = "Không phải giai đoạn chuẩn bị, không thể đặt cược", -- 非准备阶段不能下注"
    god_escort_txt_79 = "Hành trình bay này sẽ mở thưởng lúc %s", -- 该航线将在%s开奖"
    god_escort_txt_80 = "Hành trình bay này đã mở thưởng", -- 该航线已开奖"
    god_escort_txt_81 = "Đếm ngược:", -- 倒计时:"
    god_escort_txt_82 = "Trợ giúp năng lượng", -- 能量助力"
    god_escort_txt_83 = "Năng lượng bay", -- 远航能量"
    god_escort_txt_84 = "cái", -- 个"
    god_escort_txt_85 = "Tạm không có", -- 暂无"
    god_escort_txt_86 = "Vòng thứ %s", -- 第%s轮"
    god_escort_txt_87 = "Làm mới thành công", -- 刷新成功"
    god_escort_txt_88 = "Chuyến hóa thành công", -- 转化成功"
    god_escort_txt_89 = "Mua", -- 购买"
    god_escort_txt_100 = "Hạn mua server %s/%s", -- 全服限购%s/%s"
    god_escort_txt_101 = "Hạn mua %s/%s", -- 限购%s/%s"
    god_escort_txt_102 = "Số lượng hàng không đủ", -- 商品数量不足"
    god_escort_txt_103 = "Trong Ba lô tạm thời không có vật phẩm có thể chuyển hóa", -- 背包中暂无可转化物品"
    god_escort_txt_104 = "Không đủ vật phẩm chuyển hóa", -- 转化物品不足"
    god_escort_txt_105 = "Tạm chưa có người lên BXH", -- 暂无人上榜"
    god_escort_txt_106 = "Xác nhận tiêu %s để làm mới 1 lần?", -- 确认花费%s进行一次刷新？"
    god_escort_txt_107 = "Kim Cương", -- 钻石"
    god_escort_txt_108 = "Xác nhận muốn đặt cược", -- 您确定要下注吗"
    god_escort_txt_109 = "Xác nhận muốn chuyển hóa thành năng lượng không", -- 您确定要转化为能量吗"
    god_escort_txt_110 = "Xác nhận muốn dùng %s để trợ lực không", -- 您确定要消耗%s助力吗"
    god_escort_txt_111 = "Chỉ có thể đặt cược 1 lần", -- 仅可下注一次"
    god_escort_txt_112 = "Tạm không có số liệu", -- 暂无数据"
    god_escort_txt_113 = "Đang CD làm mới, hãy thử lại sau", -- 刷新冷却中,请稍后再试"
    god_escort_txt_114 = "Vũ trụ hiện tại chưa mở", -- 当前宇宙暂未开启"
    god_escort_txt_115 = "Chỉ có thể trợ giúp phi thuyền của mình!", -- 仅能助威自己的飞船！"
    god_escort_txt_116 = "Phi thuyền này chưa đạt đến giai đoạn điều chỉnh Xung Kích", -- 该飞船未达到冲刺调整阶段"
    god_escort_txt_117 = "Ít nhất trợ giúp 10 năng lượng ", -- 最低助威能量10，当前能量不足
    god_escort_txt_118 = "Không đủ đạo cụ", -- 道具不足
    god_escort_txt_119 = "BXH", -- 排行榜
    god_escort_txt_120 = "đạo cụ cổ vũ", -- 辅助助力
    god_escort_txt_121 = "Đặt Cược", -- 下注
    god_escort_txt_122 = "Năng lượng đổi về không thể nhiều hơn giới hạn năng lượng đổi trong ngày", -- 超过今日可兑换能量上限
    god_escort_txt_123 = "Không đủ sản phẩm", -- 商品不足
    god_escort_txt_124 = "Vượt quá số lượng được mua 1 lần", -- 超过单次购买上限
    god_escort_txt_125 = "Xác nhận mua?", -- 您确定要购买吗? 
    god_escort_txt_126 = "Không thể tăng thêm, đã đạt đến giới hạn Đặt Cược đơn", -- 无法继续增加，已经达到单次投注的上限
    god_escort_txt_1000 = "",
    ["A_Preparation"] = "Giai đoạn Chuẩn Bị", -- 准备阶段
    ["B_Navigation"] = "Giai đoạn Viễn Chinh", -- 航行阶段
    ["C_Rest"] = "Giai đoạn Điều Chỉnh", -- 休整阶段
    ["D_Sprint"] = "Giai đoạn Xung Kích", -- 冲刺阶段
    ["E_Settlement"] = "Giai đoạn Kết Toán", -- 结算阶段
    ["A_Empty"] = "Thời kì ngừng", -- 停摆期
    ["F_Wait"] = "Thời kì nghỉ ngơi", -- 休息期
    ["element_universe"] = "Nguyên tố Vũ Trụ", -- 元素宇宙
    ["power_universe"] = "Lực lượng Vũ Trụ", -- 力量宇宙
    ["primitive_universe"] = "Vũ Trụ Nguyên Thủy", -- 原始宇宙
    ["original_force_universe"] = "Nguyên Lực Vũ Trụ", -- 原力宇宙
    ["spirit_universe"] = "Linh Tính Vũ Trụ", -- 灵性宇宙
    ["rational_universe"] = "Lí Tính Vũ Trụ", -- 理性宇宙
    ["A_waitting"] = "Đang chuẩn bị", -- 准备中
    ["B_moving"] = "Đang bay", -- 航行中
    ["C_resting"] = "Đang bổ sung", -- 补给中
    ["D_sprinting"] = "Đang xung kích", -- 冲刺中
    ["E_settling"] = "Đang kết toán" -- 结算中
}

-- 宇宙名称
game_god_escort_helper.universeKey = {
    [1] = "primitive_universe", -- 原始宇宙
    [2] = "original_force_universe", -- 原力宇宙
    [3] = "element_universe", -- 元素宇宙
    [4] = "spirit_universe", -- 灵性宇宙
    [5] = "power_universe", -- 力量宇宙
    [6] = "rational_universe" -- 理性宇宙
}

game_god_escort_helper.universeImg = {"universe_01_yuanshi.png", "universe_02_yuanli.png", "universe_03_yuansu.png", "universe_04_lingxing.png", "universe_05_liliang.png", "universe_06_lixing.png"}

game_god_escort_helper.betTouchPriority = GLOBAL_TOUCH_PRIORITY - 1
game_god_escort_helper.achieveTouchPriorityBase = GLOBAL_TOUCH_PRIORITY - 4
game_god_escort_helper.achieveTouchPriority = GLOBAL_TOUCH_PRIORITY - 5
game_god_escort_helper.shopTouchPriority = GLOBAL_TOUCH_PRIORITY - 1
game_god_escort_helper.powerChangeTouchPriorityBase = GLOBAL_TOUCH_PRIORITY - 4
game_god_escort_helper.powerChangeTouchPriority = GLOBAL_TOUCH_PRIORITY - 5
game_god_escort_helper.voyagePreTouchPriorityBase = GLOBAL_TOUCH_PRIORITY - 4
game_god_escort_helper.voyagePreTouchPriority = GLOBAL_TOUCH_PRIORITY - 5
game_god_escort_helper.voyagePreAssistTouchPriorityBase = GLOBAL_TOUCH_PRIORITY - 7
game_god_escort_helper.voyagePreAssistTouchPriority = GLOBAL_TOUCH_PRIORITY - 8

game_god_escort_helper.exchangeTouchPriorityBase = GLOBAL_TOUCH_PRIORITY - 4
game_god_escort_helper.exchangeTouchPriority = GLOBAL_TOUCH_PRIORITY - 5

game_god_escort_helper.yhjlTouchPriorityBase = GLOBAL_TOUCH_PRIORITY - 4
game_god_escort_helper.yhjlTouchPriority = GLOBAL_TOUCH_PRIORITY - 5

game_god_escort_helper.detailTouchPriorityBase = GLOBAL_TOUCH_PRIORITY - 9
game_god_escort_helper.detailTouchPriority1 = GLOBAL_TOUCH_PRIORITY - 10
game_god_escort_helper.detailTouchPriority2 = GLOBAL_TOUCH_PRIORITY - 11

game_god_escort_helper.noticeTouchPriorityBase = GLOBAL_TOUCH_PRIORITY - 12
game_god_escort_helper.noticeTouchPriority = GLOBAL_TOUCH_PRIORITY - 13

-- 点击刷新按钮间隔时间
game_god_escort_helper.refreshInterval = 3
--[[
    押镖阶段
]]
game_god_escort_helper.state = {
    [0] = "A_Empty", -- 等待期,权限 购买商品，转化能量
    [1] = "B_Gaming" -- 游戏期,进入gamingState阶段
}

--[[
    阶段
    根据后端的sort对应
]]
game_god_escort_helper.sortStage = {
    [0] = "A_Empty", -- 等待期
    [1] = "A_Preparation", -- 准备阶段
    [2] = "B_Navigation", -- 航行阶段
    [3] = "C_Rest", -- 休整阶段
    [4] = "D_Sprint", -- 冲刺阶段
    [5] = "E_Settlement", -- 结算阶段
    [6] = "F_Wait" -- 等待期
}

game_god_escort_helper.shipStatus = {
    [0] = "A_Empty", -- 等待期
    [1] = "A_waitting", -- 准备中
    [2] = "B_moving", -- 航行中
    [3] = "C_resting", -- 补给中
    [4] = "D_sprinting", -- 冲刺中
    [5] = "E_settling", -- 结算中
    [6] = "F_Wait" --
}

-- step为key
game_god_escort_helper.shipPos = {
    [1] = {
        {-258.0, 42},
        {-255.0, -6},
        {-252.6, -61},
        {-237.2, -128},
        {-125.3, -138.6},
        {-35.1, -154.5},
        {55.1, -156},
        {118.2, -143.4}
    },
    [2] = {
        {-182.0, 34},
        {-190.0, -2},
        {-179.6, -41},
        {-157.2, -83},
        {-83.3, -90.6},
        {-26.1, -110.5},
        {36.1, -110},
        {71.2, -89.4}
    },
    [3] = {
        {-105.0, 22},
        {-98.0, 3},
        {-97.6, -18},
        {-90.2, -43},
        {-49.3, -48.6},
        {-19.1, -67.5},
        {16.1, -60},
        {32.2, -46.4}
    },
    [4] = {
        {-23.0, 12},
        {-32.0, 6},
        {-25.6, 3},
        {-32.2, -9},
        {-15.3, -9.6},
        {-10.1, -20.5},
        {-0.9, -18},
        {2.2, -13.4}
    }
}

-- step为key
game_god_escort_helper.shipScale = {
    1,
    0.9,
    0.8,
    0.7
}
--[[
    阶段持续时间
    根据后端的sort对应
]]
game_god_escort_helper.sortTime = {
    [1] = 150,
    [2] = 60,
    [3] = 30,
    [4] = 60,
    [5] = 60
}

local function safeDecode(field)
    local config = getConfig(field)
    if config and config.getFormatBuffer then
        local tb = json.decode(config:getFormatBuffer() or "") or {}
        local newTb = {}
        for k, v in pairs(tb) do
            v.id = tonumber(k)
            table.insert(newTb, v)
        end
        table.sort(
            newTb,
            function(a, b)
                return a.id < b.id
            end
        )
        return newTb
    end
    return {}
end
game_god_escort_helper.safeDecode = safeDecode

game_god_escort_helper.cfg = {
    highway_time = safeDecode(game_config_field.highway_time),
    highway_ship = safeDecode(game_config_field.highway_ship),
    highway_task = safeDecode(game_config_field.highway_task),
    highway_reward = safeDecode(game_config_field.highway_reward),
    highway_shop = safeDecode(game_config_field.highway_shop),
    highway_num = safeDecode(game_config_field.highway_num),
    highway_lack = safeDecode(game_config_field.highway_lack),
    highway_txt = safeDecode(game_config_field.highway_txt),
    highway_trans = safeDecode(game_config_field.highway_trans)
}

game_god_escort_helper.stageFunctionality = {
    ["A_HeatUp"] = {
        -- 预热阶段
        browseInterfaces = true, -- 可进行各个界面游览
        placeBets = true, -- 可下注
        shopPurchases = true, -- 可商店购买
        energyConversion = true, -- 可能量转换
        viewAchievements = true -- 可成就查看领取
    },
    ["B_Preparation"] = {
        -- 赛事-准备阶段
        browseInterfaces = true, -- 可进行各个界面游览
        placeBets = true, -- 可下注
        shopPurchases = true, -- 可商店购买
        energyConversion = true, -- 可能量转换
        viewAchievements = true -- 可成就查看领取
    },
    ["C_Navigation"] = {
        -- 赛事-航行阶段
        browseInterfaces = true, -- 可进行各个界面游览
        shopPurchases = true, -- 可商店购买
        energyConversion = true, -- 可能量转换
        viewAchievements = true -- 可成就查看领取
    },
    ["D_Rest"] = {
        -- 赛事-休整阶段
        browseInterfaces = true, -- 可界面游览
        shopPurchases = true, -- 可商店购买
        energyConversion = true, -- 可能量转换
        viewAchievements = true, -- 可成就查看领取
        shipCheer = true -- 可飞船助威干扰
    },
    ["E_Sprint"] = {
        -- 赛事-冲刺阶段
        browseInterfaces = true, -- 可界面游览
        shopPurchases = true, -- 可商店购买
        energyConversion = true, -- 可能量转换
        viewAchievements = true, -- 可成就查看领取
        shipCheer = true -- 可飞船助威干扰
    },
    ["F_Maintenance"] = {
        -- 维护期
        browseInterfaces = true, -- 可进行各个界面游览
        placeBets = true, -- 可下注
        shopPurchases = true, -- 可商店购买
        energyConversion = true, -- 可能量转换
        viewAchievements = true -- 可成就查看领取
    },
    ["G_Downtime"] = {
        -- 停摆期
        browseInterfaces = true, -- 可进行各个界面游览
        shopPurchases = true, -- 可商店购买
        energyConversion = true, -- 可能量转换
        viewAchievements = true -- 可成就查看领取
    }
}

-- 获取当前阶段的功能可用性
function game_god_escort_helper.getFunctionality(self, stateId)
    return self.stageFunctionality[self:getStateKey(stateId)]
end

-- 检查某个功能在当前阶段是否可用
function game_god_escort_helper.isFunctionAvailable(self, stateId, functionName)
    local functionality = self:getFunctionality(stateId)
    if functionality then
        return functionality[functionName] or false
    else
        return false
    end
end

function game_god_escort_helper.getStateKey(self, stateId)
    return self.gamingState[stateId]
end

-- 获取宇宙配置
function game_god_escort_helper.getUniverseConfig(self, universeId)
    return self.cfg.highway_lack[universeId]
end

-- 获取所有宇宙配置
function game_god_escort_helper.getAllUniverseConfig(self)
    -- local universeConfig = {}
    -- for i = 1, #self.universeKey do
    --     universeConfig[i] = self:getUniverseConfig(i)
    -- end
    return self.universeKey
end

function game_god_escort_helper.getCurState(self)
    local readyTime = self.cfg.highway_time[1].ready_time
    local endTime = self.cfg.highway_time[#self.cfg.highway_time].end_time
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local current_time = os.date("*t", server_time)
    local hour, minute, second = readyTime:match("(%d+):(%d+):(%d+)")
    local readyTimeToday =
        os.time(
        {
            year = current_time.year,
            month = current_time.month,
            day = current_time.day,
            hour = tonumber(hour),
            min = tonumber(minute),
            sec = tonumber(second)
        }
    )
    local hour, minute, second = endTime:match("(%d+):(%d+):(%d+)")
    local endTimeToday =
        os.time(
        {
            year = current_time.year,
            month = current_time.month,
            day = current_time.day,
            hour = tonumber(hour),
            min = tonumber(minute),
            sec = tonumber(second)
        }
    )
    if server_time >= readyTimeToday and server_time < endTimeToday then
        return 1
    else
        return 0
    end
end
-- 获取阶段翻译
function game_god_escort_helper.getSortTx(self, sort)
    return self.txt[self.sortStage[sort]]
end

function game_god_escort_helper:timeToToday(time)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local current_time = os.date("*t", server_time)
    local hour, minute, second = time:match("(%d+):(%d+):(%d+)")
    local endTimeToday =
        os.time(
        {
            year = current_time.year,
            month = current_time.month,
            day = current_time.day,
            hour = tonumber(hour),
            min = tonumber(minute),
            sec = tonumber(second)
        }
    )
    return endTimeToday
end

-- 获取阶段倒计时剩余时间
function game_god_escort_helper.getStageRemainTime(self, round_id, sort, step)
    -- local state = self:getCurState()
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local remainTime = -1
    if round_id == 0 then
        local readyTime = self.cfg.highway_time[1].ready_time
        local server_time = game_data:getUserStatusDataByKey("server_time")
        local current_time = os.date("*t", server_time)
        local hour, minute, second = readyTime:match("(%d+):(%d+):(%d+)")
        local readyTimeToday =
            os.time(
            {
                year = current_time.year,
                month = current_time.month,
                day = current_time.day,
                hour = tonumber(hour),
                min = tonumber(minute),
                sec = tonumber(second)
            }
        )
        if server_time >= readyTimeToday then
            readyTimeToday = readyTimeToday + 24 * 60 * 60 -- 加一天（24小时）
        end
        local remaining_time = readyTimeToday - server_time
        return remaining_time
    else
        -- local readyTime = self.cfg.highway_time[round_id].end_time
        -- local server_time = game_data:getUserStatusDataByKey("server_time")
        -- local current_time = os.date("*t", server_time)
        -- local hour, minute, second = readyTime:match("(%d+):(%d+):(%d+)")
        -- local readyTimeToday = os.time({
        --     year = current_time.year,
        --     month = current_time.month,
        --     day = current_time.day,
        --     hour = tonumber(hour),
        --     min = tonumber(minute),
        --     sec = tonumber(second)
        -- })
        -- local remaining_time = readyTimeToday - server_time
        -- return remaining_time
        local endTimeToday
        if sort == 6 then -- 等待期
            local endTime = self.cfg.highway_time[round_id].end_time
            endTimeToday = self:timeToToday(endTime)
        else
            local ready_time = self.cfg.highway_time[round_id].ready_time
            if sort == 1 then
                endTimeToday = self:timeToToday(ready_time) + self.sortTime[1]
            end
            if sort == 2 then
                endTimeToday = self:timeToToday(ready_time) + self.sortTime[1] + (step - 1) * self.sortTime[3] + step * self.sortTime[2]
            end
            if sort == 3 then
                endTimeToday = self:timeToToday(ready_time) + self.sortTime[1] + (step - 1) * self.sortTime[2] + (step - 1) * self.sortTime[3]
            end
            if sort == 4 then
                endTimeToday = self:timeToToday(ready_time) + self.sortTime[1] + (step - 1) * self.sortTime[2] + (step - 2) * self.sortTime[3] + self.sortTime[4]
            end
            if sort == 5 then
                endTimeToday = self:timeToToday(ready_time) + self.sortTime[1] + (step - 1) * self.sortTime[2] + (step - 2) * self.sortTime[3] + self.sortTime[4] + self.sortTime[5]
            end
        end
        local remaining_time = endTimeToday - server_time
        return remaining_time
    end
end

--[[
    随机获取指定sort的文本
]]
function game_god_escort_helper.getRandomTxtBySort(self, sort)
    local txt = self.cfg.highway_txt
    local data = {}
    for i = 1, #txt do
        if txt[i].sort == sort then
            table.insert(data, txt[i])
        end
    end
    return data[math.random(1, #data)].des
end

function game_god_escort_helper.getTxtById(self, id)
    local txt = self.cfg.highway_txt
    return txt[id].des
end

--[[
    创建飞船图片
]]
function game_god_escort_helper.createShipSprite(self, shipLv)
    local sprite = CCSprite:createWithSpriteFrameName("dart_ship_" .. shipLv .. ".png")
    return sprite
end

--[[
    获取总里程
]]
function game_god_escort_helper.getTotalMileage(self, shipData, round_id, sort, step, ts_start, achieve_ts)
    if not shipData then
        return 0
    end
    if type(shipData) == "table" and game_util:getTableLen(shipData) == 0 then
        return 0
    end
    if not round_id or (round_id == 0) then
        return 0
    end
    if sort == 0 then
        return 0
    end
    if sort == 6 then
        return shipData.mileage or 0
    end
    local point = self.cfg.highway_time[tonumber(round_id)].point
    local all = shipData.all or {}
    local steps = shipData.steps or {}
    local lv = shipData.lv or 1
    local server_time = math.floor(game_data:getVirtualServerTime())
    local maxTime = self.sortTime[2]
    local time = server_time - ts_start
    if time > maxTime then
        time = maxTime
    end
    local base = self.cfg.highway_ship[lv].basic

    -- 计算sort2的里程
    local calculateSort2Mileage = function()
        local mileage = 0
        local maxTime = self.sortTime[2]
        local _step = step
        if sort ~= 2 then
            _step = _step - 1
        end
        for i = 1, _step do
            local speed_add1 = 0
            local speed_add2 = 0
            for j = 1, i do
                local _data = steps[tostring(j)] or {}
                speed_add1 = speed_add1 + (_data.speed_add1 or 0)
                speed_add2 = speed_add2 + (_data.speed_add2 or 0)
            end
            local value1 = base[1] + speed_add1
            local value2 = base[2] + speed_add2
            value1 = value1 > 0 and value1 or 0
            value2 = value2 > 0 and value2 or 0
            local time
            if i ~= step then -- 以前的阶段时间直接是最大值
                time = maxTime
            else
                time = server_time - ts_start
                if time > maxTime then
                    time = maxTime
                end
            end
            mileage = mileage + (value1 + value2) * time
        end
        if mileage >= point then -- 非第5个阶段,总里程不会超过里程碑点
            mileage = point
        end
        return mileage
    end

    -- 计算sort4的里程
    local calculateSort4Mileage = function()
        local mileage = 0
        local maxCcTime = self.sortTime[4]
        local ccTime = server_time - ts_start
        if ccTime > maxCcTime then
            ccTime = maxCcTime
        end
        if sort == 5 then
            ccTime = maxCcTime
        end
        local speed_add1 = 0
        local speed_add2 = 0
        for j = 1, step do
            local _data = steps[tostring(j)] or {}
            speed_add1 = speed_add1 + (_data.speed_add1 or 0)
            speed_add2 = speed_add2 + (_data.speed_add2 or 0)
        end
        local value1 = base[1] + speed_add1
        local value2 = base[2] + speed_add2
        value1 = value1 > 0 and value1 or 0
        value2 = value2 > 0 and value2 or 0
        mileage = mileage + (value1 + value2) * ccTime
        return mileage
    end

    local totalMileage = 0
    if sort == 1 then -- 准备阶段
        totalMileage = 0
    end
    if sort == 2 then -- 航行阶段
        totalMileage = calculateSort2Mileage()
    end
    if sort == 3 then -- 调整阶段
        totalMileage = calculateSort2Mileage()
    end

    if sort == 4 then -- 冲刺阶段,将在sort5的时候强行结算,sort4过程中如果到达冲刺,里程不会继续增加,如果没到,里程继续增加直到冲刺
        totalMileage = calculateSort2Mileage()
        if totalMileage < point then -- 未进入冲刺,继续跑
            totalMileage = totalMileage + calculateSort4Mileage()
        end
        if totalMileage >= point then -- 非第5个阶段,总里程不会超过里程碑点
            totalMileage = point
        end
    end

    if sort == 5 then -- 结算航行阶段
        if not achieve_ts or (achieve_ts == 0) then -- 之前阶段未达到里程碑,按前面速度算,速度按sort2算
            totalMileage = calculateSort2Mileage()
            totalMileage = totalMileage + calculateSort4Mileage()
            local ccTime = server_time - ts_start
            local maxCcTime = self.sortTime[5]
            if ccTime > maxCcTime then
                ccTime = maxCcTime
            end
            local speed_add1 = 0
            local speed_add2 = 0
            for j = 1, step do
                local _data = steps[tostring(j)] or {}
                speed_add1 = speed_add1 + (_data.speed_add1 or 0)
                speed_add2 = speed_add2 + (_data.speed_add2 or 0)
            end
            local value1 = base[1] + speed_add1
            local value2 = base[2] + speed_add2
            value1 = value1 > 0 and value1 or 0
            value2 = value2 > 0 and value2 or 0
            local mileage = (value1 + value2) * ccTime
            totalMileage = totalMileage + mileage
        else -- 有里程碑时间
            -- 里程碑距离
            totalMileage = point
            -- sort5之前的冲刺距离
            local mileage = 0
            local time = ts_start - achieve_ts
            if time < 0 then
                time = 0
            end
            local speed_add1 = 0
            local speed_add2 = 0
            for j = 1, step do
                local _data = steps[tostring(j)] or {}
                speed_add1 = speed_add1 + (_data.speed_add1 or 0)
                speed_add2 = speed_add2 + (_data.speed_add2 or 0)
            end
            local value1 = base[1] + speed_add1
            local value2 = base[2] + speed_add2
            value1 = value1 > 0 and value1 or 0
            value2 = value2 > 0 and value2 or 0
            mileage = (value1 + value2) * time
            totalMileage = totalMileage + mileage
            -- sort5的距离
            local maxCcTime = self.sortTime[5]
            local ccTime = server_time - ts_start
            if ccTime > maxCcTime then
                ccTime = maxCcTime
            end
            mileage = (value1 + value2) * ccTime
            totalMileage = totalMileage + mileage
        end
    end

    return totalMileage
end

function game_god_escort_helper:getHasById(id)
    if id == 1 then -- 以太能源
        return game_data:getItemCountByCid(tostring(9101351)) or 0
    elseif id == 2 then -- 穿梭器
        return game_data:getItemCountByCid(tostring(9101347)) or 0
    elseif id == 3 then -- 量子仓
        return game_data:getItemCountByCid(tostring(9101349)) or 0
    elseif id == 4 then -- 永凝剂
        return game_data:getItemCountByCid(tostring(9101352)) or 0
    elseif id == 5 then -- 人造墙
        return game_data:getItemCountByCid(tostring(9101348)) or 0
    elseif id == 6 then -- 小裂缝
        return game_data:getItemCountByCid(tostring(9101350)) or 0
    end
end

function game_god_escort_helper:getAttrDatasBySteps(steps)
    local steps = steps or {}
    local attrDatas = {
        ship_income_add = 0,
        speed_add1 = 0,
        speed_add2 = 0
    }
    for k, v in pairs(steps) do
        attrDatas["ship_income_add"] = attrDatas["ship_income_add"] + v.ship_income_add
        attrDatas["speed_add1"] = attrDatas["speed_add1"] + v.speed_add1
        attrDatas["speed_add2"] = attrDatas["speed_add2"] + v.speed_add2
    end
    return attrDatas
end

function game_god_escort_helper:isUniverseOpen(universeId)
    -- 计算出周几
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local current_time = os.date("*t", server_time)
    local weekday = current_time.wday - 1
    if weekday == 0 then
        weekday = 7 -- 如果结果为0，则表示星期日
    end
    -- 读取配置
    local open_area = self.cfg.highway_time[1].open_area or {} -- 开启的宇宙数据
    local openData = open_area[weekday] or {}
    -- 判断universeId是否在openData中
    return game_util:idInTableById(universeId, openData)
end

--[[
    奖励红点
    idx 0:全部 idx 3:量子仓奖励 idx 4:光年里程碑
]]
function game_god_escort_helper:isRewardRed(idx)
    local gift_box = game_data.m_cacheData.gift_box or {}
    local cfg = self.cfg.highway_reward
    for k, v in pairs(gift_box) do
        local sort = cfg[tonumber(k)].sort
        if (idx == 0 and (sort == 2 or sort == 3)) or idx == sort then
            if v.status == 1 then
                return true
            end
        end
    end
    return false
end

function game_god_escort_helper:isTaskRed(tasks)
    local tasks = tasks or {}
    local cfg = self.cfg.highway_task
    for k, v in pairs(tasks) do
        if v.status == 1 then
            return true
        end
    end
    return false
end

function game_god_escort_helper.sendHttpRequest(callback, url, method, params_, tag, loadingFlag, retrunFlag, noresFlag)
    if tag then
        tag = tag .. "_" .. game_data:getGlobalIdx()
    end
    network.sendHttpRequest(callback, url, method, params_, tag, loadingFlag, retrunFlag, noresFlag)
end

return game_god_escort_helper
