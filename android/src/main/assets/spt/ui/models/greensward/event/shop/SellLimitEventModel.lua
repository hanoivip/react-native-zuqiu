local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local AdventureShopModel = require("ui.models.greensward.event.shop.AdventureShopModel")
local SellLimitEventModel = class(AdventureShopModel, "SloganEventModel")

--23	豪门限时折扣店	豪门限时折扣店
function SellLimitEventModel:ctor()
    SellLimitEventModel.super.ctor(self)
end

function SellLimitEventModel:GetRemainTime()
    local endTime = Time.unscaledTime
    local leftTime = self.data.l_t or 0
    return leftTime - endTime + self.startTime or 0
end

function SellLimitEventModel:IsShowResidualTimer()
    return true
end

function SellLimitEventModel:GetEventIcon()
    local remainTime = self:GetRemainTime()
    local eventIconName = self.staticData.eventIndex[1]
    if remainTime > 0 then
        return eventIconName .. "_Open"
    else
        return eventIconName .. "_Close"
    end
end

function SellLimitEventModel:GetEndTips()
    local remainTime = self:GetRemainTime()
    if remainTime < 1 then
        return "sell_limit_end_tip"
    end
end

return SellLimitEventModel
