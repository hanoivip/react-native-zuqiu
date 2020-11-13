local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LoginModel = require("ui.models.login.LoginModel")
local SGPCustomEventConstants = require("ui.common.SGPCustomEventConstants")
local SgpCustomEvent = {}

-- 统计钻石来源
function SgpCustomEvent.GetDiamond(get_type, value, info)
    if not value or tonumber(value) < 1 then
        return
    end
    if info then
        luaevt.trig("HoolaiBISendEconomy", "yb", tonumber(value), 0, "earning", info.phylum and SGPCustomEventConstants.Phylum[info.phylum] or info.phylum, info.classfield and SGPCustomEventConstants.ClassField[info.classfield] or info.classfield, info.genus and SGPCustomEventConstants.Genus[info.genus] or info.genus)
        return
    end
    luaevt.trig("HoolaiBISendEconomy", "yb", tonumber(value), 0, "earning", SGPCustomEventConstants.DiamondSource[get_type], nil, nil)
end

-- 2.钻石 消费 钻石消费時
function SgpCustomEvent.ConsumeDiamond(spend_type, value, info)
    if info then
        luaevt.trig("HoolaiBISendEconomy", "yb", tonumber(value), 0, "expenditure", info.phylum and SGPCustomEventConstants.Phylum[info.phylum] or info.phylum, info.classfield and SGPCustomEventConstants.ClassField[info.classfield] or info.classfield, info.genus and SGPCustomEventConstants.Genus[info.genus] or info.genus)
    end
end

-- 统计hmb来源
function SgpCustomEvent.GetBlackDiamond(get_type, value, info)
    info = info or {}
    if not value or tonumber(value) < 1 then
        return
    end
    -- if SGPCustomEventConstants.BlackDiamondSource[info.phylum or get_type] then
        luaevt.trig("HoolaiBISendEconomy", "bkd", tonumber(value), 0, "earning", info.phylum and SGPCustomEventConstants.Phylum[info.phylum] or info.phylum, info.classfield and SGPCustomEventConstants.ClassField[info.classfield] or info.classfield, info.genus and SGPCustomEventConstants.Genus[info.genus] or info.genus)
    -- end
end

-- 统计hmb消耗
function SgpCustomEvent.ConsumeBlackDiamond(spend_type, value, info)
    info = info or {}
    -- if SGPCustomEventConstants.BlackDiamondConsume[info.phylum or spend_type] then
        luaevt.trig("HoolaiBISendEconomy", "bkd", tonumber(value), 0, "expenditure", info.phylum and SGPCustomEventConstants.Phylum[info.phylum] or info.phylum, info.classfield and SGPCustomEventConstants.ClassField[info.classfield] or info.classfield, info.genus and SGPCustomEventConstants.Genus[info.genus] or info.genus)
    -- end
end

-- 5.主线 比赛start 比赛开始时
function SgpCustomEvent.StoryMatchStart(stage_no, power_value)
    luaevt.trig("Reyun_Quest", tostring(stage_no), "a", "main")
end

-- 6.主线 比赛end 比赛结束时
function SgpCustomEvent.StoryMatchEnd(stage_no, is_win, power_value)
    luaevt.trig("Reyun_Quest", tostring(stage_no), is_win and "c" or "f", "main")
end

-- 注册
function SgpCustomEvent.Register(id)
    luaevt.trig("Reyun_Register", id, "unknown", "UNKNOWN", "-1", LoginModel.GetCurrentServer().name, "")
end

-- 登录
function SgpCustomEvent.Login()
    local playerInfoModel = PlayerInfoModel.new()
    luaevt.trig("Reyun_Login", playerInfoModel:GetID(), playerInfoModel:GetLevel(), LoginModel.GetCurrentServer().name, playerInfoModel:GetName(), "UNKNOWN", "-1")
end

-- 开始充值（点击充值档位）
function SgpCustomEvent.PaymentStart(orderID, productID, price, diamond)
    luaevt.trig("Reyun_PaymentStart", orderID, "alipay", "CNY", price, diamond or 1, productID, 1)
end

-- 充值成功
function SgpCustomEvent.Payment(orderID, productID, price, diamond)
    local playerInfoModel = PlayerInfoModel.new()
    luaevt.trig("Reyun_Payment", orderID, "alipay", "CNY", price, diamond or 1, productID, 1, playerInfoModel:GetLevel())
end

return SgpCustomEvent
