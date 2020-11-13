local Model = require("ui.models.Model")
local SetSpecial = require("data.SetSpecial")
local GiftBoxModel = class(Model, "GiftBoxModel")

function GiftBoxModel:Init(data)
    self.data = data
end

function GiftBoxModel:GetID()
    return self.data.ID
end
-- 1 人民币,2豪门币
function GiftBoxModel:GetPayType()
    return self.data.type
end

function GiftBoxModel:GetTitle()
    return self.data.name
end

function GiftBoxModel:GetPrice()
    return self.data.fee
end

function GiftBoxModel:GetOldPrice()
    return self.data.fakeFee
end

function GiftBoxModel:GetDesc()
    return self.data.desc
end

function GiftBoxModel:GetDesc0()
    return self.data.desc0
end

function GiftBoxModel:GetDescInBoardFirstLine()
    return self.data.desc1
end

function GiftBoxModel:GetDescInBoardSecondLine()
    return self.data.desc2
end

function GiftBoxModel:GetRewardContents()
    return self.data.contents
end

function GiftBoxModel:GetRewardPicIndex()
    return self.data.picIndex
end

function GiftBoxModel:GetFlag()
    return self.data.flag
end

function GiftBoxModel:GetLastTime()
    return self.data.lastTime
end

function GiftBoxModel:SetLastTime(lastTime)
    self.data.lastTime = lastTime
end

function GiftBoxModel:GetBoard()
    return self.data.board
end

function GiftBoxModel:SetBuyCounter(time)
    self.data.buyCounter = self.data.buyCounter + time
end

function GiftBoxModel:IsCanBuy()
    -- 限制次数和已购买次数进行比较
    if self.data.limitType > 0 and self.data.timesLimit then
        return tonumber(self.data.buyCounter) < self.data.timesLimit
    end

    return true
end

function GiftBoxModel:IsSpecial()
    return self.data.setSpecial or ""
end

function GiftBoxModel:GetSpecialImg(id)
    return SetSpecial[id].picIndex
end

return GiftBoxModel



