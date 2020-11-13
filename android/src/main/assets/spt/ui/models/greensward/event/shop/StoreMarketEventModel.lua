local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local AdventureShopModel = require("ui.models.greensward.event.shop.AdventureShopModel")
local StoreMarketEventModel = class(AdventureShopModel, "StoreMarketEventModel")

--24	黑市商人	黑市商人
function StoreMarketEventModel:ctor()
    StoreMarketEventModel.super.ctor(self)
end

function StoreMarketEventModel:GetRemainTime()
    local endTime = Time.unscaledTime
    local leftTime = self.data.l_t or 0
    return leftTime - endTime + self.startTime or 0
end

function StoreMarketEventModel:IsShowResidualTimer()
    return true
end

function StoreMarketEventModel:IsPreserveEvent()
    return false
end

function StoreMarketEventModel:GetEventIcon()
    return self.staticData.eventIndex[1] or ""
end

return StoreMarketEventModel
