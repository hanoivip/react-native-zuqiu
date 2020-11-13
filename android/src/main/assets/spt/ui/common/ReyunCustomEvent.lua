local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LoginModel = require("ui.models.login.LoginModel")
local ReyunCustomEvent = {}

-- 统计系统赠送的钻石
function ReyunCustomEvent.GetDiamond(get_type, value)
    if get_type == "1" then
        return
    end

    -- local playerInfoModel = PlayerInfoModel.new()
    -- luaevt.trig("Reyun_Payment", "", "FREE", "", -1, -1, "", -1, playerInfoModel:GetLevel())
end

-- 2.钻石 消费 钻石消费時
function ReyunCustomEvent.ConsumeDiamond(spend_type, value)
    local playerInfoModel = PlayerInfoModel.new()
    luaevt.trig("Reyun_Economy", spend_type, 1, tonumber(value))
end

-- 5.主线 比赛start 比赛开始时
function ReyunCustomEvent.StoryMatchStart(stage_no, power_value)
    luaevt.trig("Reyun_Quest", tostring(stage_no), "a", "main")
end

-- 6.主线 比赛end 比赛结束时
function ReyunCustomEvent.StoryMatchEnd(stage_no, is_win, power_value)
    luaevt.trig("Reyun_Quest", tostring(stage_no), is_win and "c" or "f", "main")
end

-- 注册
function ReyunCustomEvent.Register(id)
    luaevt.trig("Reyun_Register", id, "unknown", "UNKNOWN", "-1", LoginModel.GetCurrentServer().name, "")
end

-- 登录
function ReyunCustomEvent.Login()
    local playerInfoModel = PlayerInfoModel.new()
    luaevt.trig("Reyun_Login", playerInfoModel:GetID(), playerInfoModel:GetLevel(), LoginModel.GetCurrentServer().name, playerInfoModel:GetName(), "UNKNOWN", "-1")
end

-- 开始充值（点击充值档位）
function ReyunCustomEvent.ZhifuStart(orderID, productID, price, diamond)
end

-- 充值成功
function ReyunCustomEvent.Zhifu(orderID, productID, price, diamond)
end

return ReyunCustomEvent
