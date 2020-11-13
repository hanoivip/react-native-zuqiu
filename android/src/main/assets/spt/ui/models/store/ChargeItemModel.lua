﻿local ItemModel = require("ui.models.store.ItemModel")

local ChargeItemModel = class(ItemModel)

function ChargeItemModel:Init(data)
    local fdata = {}
    fdata.id = data.ID
    fdata.itemName = data.productName
    fdata.itemDesc = {
        data.desc1,
        string.gsub(tostring(data.desc2),"d%%", "%%d"),
    }
    fdata.isFirst = data.isFirst
    local desc = ""
    if data.lastTime then
        fdata.month = {}
        fdata.month.duration = data["type"]
        fdata.month.left = data.lastTime
    end
    fdata.price = data.fee
    fdata.picIndex = data.picIndex
    fdata.diamond = {
        normal = data.diamond,
        extra = data.extraDiamond,
        double = data.doubleDiamond,
    }

    fdata.detail = data.detail

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

    fdata.blackDiamond = data.blackDiamond
    -- 作为显示价格特殊用途（应sdk要求可能会与内部价格不一致）
    fdata.showPrice = data.showPrice
    self.data = fdata
end

function ChargeItemModel:GetPicIndex()
    return self.data.picIndex
end

function ChargeItemModel:IsMonthCard()
    return tobool(self.data.month)
end

function ChargeItemModel:GetItemDesc()
    local desc = ""
    if self:IsMonthCard() then
        desc = self.data.itemDesc[1]
    else
        if self.data.isFirst then
            desc = self.data.itemDesc[1]
        else
            desc = self.data.itemDesc[2]
        end
    end
    return desc
end

function ChargeItemModel:GetItemDetail()
    return self.data.detail
end

function ChargeItemModel:GetDiamond()
    local diamond = self.data.diamond.normal
    if self.data.isFirst then
        diamond = diamond + self.data.diamond.double
    else
        diamond = diamond + self.data.diamond.extra
    end
    return diamond
end

function ChargeItemModel:GetBaseDiamond()
    return self.data.diamond.normal
end

function ChargeItemModel:GetExtraDiamond()
    if self.data.isFirst then
        return self.data.diamond.double, true
    else
        return self.data.diamond.extra, false
    end
end

function ChargeItemModel:GetProductId()
    return self.data.id
end

function ChargeItemModel:GetItemName()
    return self.data.itemName
end

function ChargeItemModel:SetFirstPay(state)
    self.data.isFirst = state
end

function ChargeItemModel:GetFirstPay()
    return self.data.isFirst
end

function ChargeItemModel:GetAmount()
    local amount = tonumber(self.data.blackDiamond)
    if amount <= 0 then 
        amount = tonumber(self:GetDiamond())
    end
    return amount
end

-- 应vng sdk要求
function ChargeItemModel:GetShowPrice()
    return self.data.showPrice or self.data.price or 0
end

return ChargeItemModel
