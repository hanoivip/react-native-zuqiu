local AdventureShopModel = require("ui.models.greensward.event.shop.AdventureShopModel")
local SloganShopEventModel = class(AdventureShopModel, "SloganShopEventModel")

-- 22	豪门老字号	豪门老字号
function SloganShopEventModel:ctor()
    SloganShopEventModel.super.ctor(self)
end

function SloganShopEventModel:IsShowResidualTimer()
    return false
end

function SloganShopEventModel:IsPreserveEvent()
    return true
end

function SloganShopEventModel:GetEventIcon()
    return self.staticData.eventIndex[1] or ""
end

return SloganShopEventModel
