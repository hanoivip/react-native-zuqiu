local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PeakMysteryBox = require("data.PeakMysteryBox")
local PeakStore = require("data.PeakStore")
local ItemModel = require("ui.models.ItemModel")
local Model = require("ui.models.Model")

local PeakStoreModel = class(Model)

function PeakStoreModel:ctor()
    PeakStoreModel.super.ctor(self)
end

function PeakStoreModel:InitWithProtocol(data)
    assert(data)
    -- 目前策划写死了一个编号为1的礼盒
    self.mysteryBoxID = tostring(1)
    self.data = data
    local pp = data.pp
    if pp then
        PlayerInfoModel.new():SetPeakDiamond(pp)
    end
end

function PeakStoreModel:GetGiftBoxName()
    return PeakMysteryBox[self.mysteryBoxID].name
end

function PeakStoreModel:GetGiftBoxContents()
    -- 此处必为礼盒(策划定的)，否则有问题
    local itemModel = ItemModel.new(self:GetGiftBoxId())
    return itemModel:GetItemContent()
end

function PeakStoreModel:GetGiftBoxId()
    return PeakMysteryBox[self.mysteryBoxID].contents.item[1].id
end

-- 类型为array
function PeakStoreModel:GetDiamondPrice()
    return PeakMysteryBox[self.mysteryBoxID].price_d
end

-- 价格因次数不同而变化
function PeakStoreModel:GetDiamondPriceByTime()
    local price = self:GetDiamondPrice()
    return price[self:GetHaveBoughtGiftBoxTime() + 1] or price[self:GetHaveBoughtGiftBoxTime()]
end

-- 已购买的次数
function PeakStoreModel:GetHaveBoughtGiftBoxTime()
    return self.data.mysteryBox.d.buyCount
end

function PeakStoreModel:GetPDiamondPrice()
    return PeakMysteryBox[self.mysteryBoxID].price_pp
end

function PeakStoreModel:GetPPurchaseMaxTime()
    return self.data.mysteryBox.pp.maxBuyCount
end

function PeakStoreModel:GetPCanPurchaseTime()
    local maxTime = self:GetPPurchaseMaxTime()
    local boughtTime = self:GetPeakHaveBoughtGiftBoxTime()
    local t = maxTime - boughtTime
    if t < 0 then return 0 end
    return t
end

function PeakStoreModel:GetPeakHaveBoughtGiftBoxTime()
    return self.data.mysteryBox.pp.buyCount
end

function PeakStoreModel:GetDiamondMaxTime()
    return PeakMysteryBox[self.mysteryBoxID].times_d
end

function PeakStoreModel:GetDCanPurchaseTime()
    local maxTime = self:GetDiamondMaxTime()
    local boughtTime = self.data.mysteryBox.d.buyCount
    return maxTime - boughtTime
end

function PeakStoreModel:GetPDiamondCount()
    return tostring(PlayerInfoModel.new():GetPeakDiamond())
end

function PeakStoreModel:GetNextRefreshTime()
    return self.data.nextAutoRefreshTime
end

function PeakStoreModel:GetDataList()
    for k, v in pairs(self.data.normalItems) do
        v.price = PeakStore[tostring(v.ID)].price
        v.maxTime = PeakStore[tostring(v.ID)].timesLimit
        v.contents = self:GetContentById(v.ID)
        v.name = self:GetNameById(v.ID)
    end
    return self.data.normalItems
end

function PeakStoreModel:GetNameById(id)
    return PeakStore[tostring(id)].name
end

function PeakStoreModel:SetDataList(itemData)
    for k, v in pairs(itemData) do
        if PeakStore[tostring(v.ID)].price then
            v.price = PeakStore[tostring(v.ID)].price
            v.maxTime = PeakStore[tostring(v.ID)].timesLimit
            v.contents = self:GetContentById(v.ID)
        end
    end
    self.data.normalItems = itemData
    EventSystem.SendEvent("Refresh_Peak_Store")
end

function PeakStoreModel:SetBoughtTimeWithId(id)
    local itemsData = self.data.normalItems
    for k, v in pairs(itemsData) do
        if v.ID == id then
            v.buyCount = v.buyCount + 1
            EventSystem.SendEvent("Refresh_Peak_Store")
        end
    end
end

function PeakStoreModel:GetContentById(id)
    return PeakStore[tostring(id)].contents
end

function PeakStoreModel:GetRefreshPrice()
    return self.data.refreshPrice
end

function PeakStoreModel:SetRefreshPrice(price)
    self.data.refreshPrice = price
end

function PeakStoreModel:GetMaxRefreshTimes()
    return self.data.maxRefreshTimes
end

function PeakStoreModel:GetRefreshTimes()
    return self.data.refreshTimes
end

function PeakStoreModel:SetRefreshTimes(time)
    self.data.refreshTimes = time
end

return PeakStoreModel