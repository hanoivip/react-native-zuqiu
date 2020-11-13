local Model = require("ui.models.Model")
local Item = require("data.Item")
local StoreModel = require("ui.models.store.StoreModel")

local MonthCardMallModel = class(Model, "MonthCardMallModel")

function MonthCardMallModel:ctor()
    self.data = nil
    self.itemList = {}
    self.isMonthCard = false
    self.isSupremeMonthCard = false
end

function MonthCardMallModel:InitWithProtocol(data)
    if not data then
        return
    end
    self.data = data
    self.isMonthCard = self.data.monthCard == 1
    self.isSupremeMonthCard = self.data.superMonthCard == 1
    self.itemList = {}
    for k, v in pairs(self.data.list) do
        v.id = tostring(k)
        v.isMonthCard = self.isMonthCard
        v.isSupremeMonthCard = self.isSupremeMonthCard
        table.insert(self.itemList, v)
    end
    table.sort(self.itemList, function(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end)
end

function MonthCardMallModel:GetItemList()
    return self.itemList or {}
end

-- 是否是月卡用户，月卡生效中
function MonthCardMallModel:IsMonthCard()
    return self.isMonthCard
end

-- 是否是至尊月卡用户，至尊月卡生效中
function MonthCardMallModel:IsSupremeMonthCard()
    return self.isSupremeMonthCard
end

function MonthCardMallModel:UpdateAfterBought(id, cnt)
    if not self.data then
        return
    end
    self.data.list[id].cnt = cnt
    for k, itemData in pairs(self.itemList) do
        if itemData.id == id then
            itemData.cnt = cnt
            return
        end
    end
end

return MonthCardMallModel
