local ItemModel = require("ui.models.store.ItemModel")

local StoreItemModel = class(ItemModel)

--[[
local testData = {
    id = "cn.capstones.igoal.m240",
    highlight = true,
    hot = {
        text = "人气1",
        color = StoreModel.HotColor.RED,
    },
    itemName = "itemName",
    price = "120",
    picIndex = nil,
    cnt = 0, -- 已购买次数
}
--]]
function StoreItemModel:Init(data)
    local fdata = clone(data)

    if data.board == 1 then
        fdata.highlight = false
    elseif data.board == 2 then
        fdata.highlight = true
    end

    if data.flagLogic == 1 or (data.flagLogic == 2 and data.isFirst) then
        fdata.hot = {
            text = data.content,
            color = ItemModel.FlagColors[data.flag],
        }
    end

    if #data.price > 1 then
        if data.cnt == data.timesLimit then
            fdata.price = tonumber(data.price[data.cnt])
        else
            fdata.price = tonumber(data.price[data.cnt + 1])
        end
    elseif #data.price == 1 then
        fdata.price = tonumber(data.price[1])
    else
        fdata.price = 0
    end

    if type(fdata.bagLimit) == "number" and fdata.bagLimit > 0 then
        fdata.contents.bagLimit = fdata.bagLimit
    end

    self.data = fdata
end

function StoreItemModel:GetBoughtCount()
    return self.data.cnt
end

function StoreItemModel:GetTimesLimit()
    return self.data.timesLimit
end

function StoreItemModel:GetPicIndex()
    return self.data.picIndex
end

function StoreItemModel:GetContents()
    return self.data.contents
end

function StoreItemModel:GetBagLimit()
    return self.data.bagLimit
end

function StoreItemModel:GetQuality()
    return self.data.quality
end

function StoreItemModel:GetItemDesc()
    local desc = ""
    if self.data.limitType == 1 then
        desc = lang.trans("buy_times_limit_activity", self.data.timesLimit - self.data.cnt, self.data.timesLimit)
    elseif self.data.limitType == 2 then
        desc = lang.trans("buy_times_limit_everyday", self.data.timesLimit - self.data.cnt, self.data.timesLimit)
    elseif self.data.limitType == 3 then
        desc = lang.trans("buy_times_limit_permanently", self.data.timesLimit - self.data.cnt, self.data.timesLimit)
    end
    return desc
end

function StoreItemModel:GetDetailItemDesc()
    local desc = ""
    if self.data.limitType == 1 then
        desc = lang.trans("buy_times_limit_activity_2", self.data.timesLimit - self.data.cnt, self.data.timesLimit)
    elseif self.data.limitType == 2 then
        desc = lang.trans("buy_times_limit_everyday_2", self.data.timesLimit - self.data.cnt, self.data.timesLimit)
    elseif self.data.limitType == 3 then
        desc = lang.trans("buy_times_limit_permanently_2", self.data.timesLimit - self.data.cnt, self.data.timesLimit)
    end
    return desc
end

function StoreItemModel:GetProductId()
    return self.data.id
end

function StoreItemModel:GetItemName()
    return self.data.name
end

return StoreItemModel
