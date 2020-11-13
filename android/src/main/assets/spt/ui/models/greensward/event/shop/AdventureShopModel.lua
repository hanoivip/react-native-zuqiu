local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local AdventureStore = require("data.AdventureStore")
local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local AdventureShopModel = class(GeneralEventModel, "AdventureShopModel")

function AdventureShopModel:ctor()
    AdventureShopModel.super.ctor(self)
    self.isIconKeep = true
end

function AdventureShopModel:InitData(key, data, buildModel)
    AdventureShopModel.super.InitData(self, key, data, buildModel)
    self.startTime = Time.unscaledTime
end

function AdventureShopModel:RefreshData(data)
    AdventureShopModel.super.RefreshData(self, data)
    self.startTime = Time.unscaledTime
end

function AdventureShopModel:IsShowResidualTimer()
    return false
end

function AdventureShopModel:TriggerEvent()
    AdventureShopModel.super.TriggerEvent(self)
    local effectPos = self:GetEffectPos()
    local effectState = AdventureShopModel.EventStatus.Unlock
    EventSystem.SendEvent("GreenswardEventModel_StatusChange", self, effectPos, effectState)
end

function AdventureShopModel:IsPreserveEvent()
    return true
end

function AdventureShopModel:HasEvent()
    return true
end

function AdventureShopModel:GetEventResName()
    return "StoreEvent"
end

function AdventureShopModel:InitWithProtocol(data)
    self.shopData = data
end

function AdventureShopModel:GetStoreList()
    local shopList = {}
    local shopType = self:GetShopType()
    local shopStatic = AdventureStore[shopType] or {}
    for i, v in ipairs(self.shopData) do
        local itemId = tostring(v.id)
        local staticData = shopStatic[itemId]
        v.staticData = staticData
        local itemType = staticData.itemType
        local itemNum = staticData.itemNum
        itemId = staticData.itemId or itemId
        local purchaseArgs = {
            boughtTime = v.buy,
            contents = staticData.contents,
            limitAmount = staticData.limitAmount,
            itemId = itemId,
            currencyType = staticData.currencyType,
            price = staticData.price,
            limitType = staticData.limitType,
            plateType = tonumber(staticData.plate),
            itemType = itemType,
            itemNum = itemNum
        }
        v.purchaseArgs = purchaseArgs
        table.insert(shopList, v)
    end
    return shopList
end

function AdventureShopModel:RunOutOfTime()
    self.runOutOfTime = true
end

function AdventureShopModel:IsCanBuyInBuyTime()
    return not self.runOutOfTime
end

function AdventureShopModel:SetShopType(greenswardShopType)
    self.greenswardShopType = greenswardShopType
end

function AdventureShopModel:GetShopType()
    return tostring(self.greenswardShopType)
end

function AdventureShopModel:GetEndTips()
    return nil
end

return AdventureShopModel
