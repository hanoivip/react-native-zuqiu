local Model = require("ui.models.Model")
local LeadIntoAidModel = class(Model, "LeadIntoAidModel")

function LeadIntoAidModel:ctor()
    LeadIntoAidModel.super.ctor(self)
end

function LeadIntoAidModel:Init(data)
    self.data = data or {}
end

function LeadIntoAidModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function LeadIntoAidModel:IsOpen()
    return self.data.isOpen
end

function LeadIntoAidModel:GetBeAidCount()
    local base = self.data.mystery.base
    return base and base.m_r_cnt or 0
end

function LeadIntoAidModel:GetMaxAidCount()
    local base = self.data.mystery.base
    return base and base.refreshMaxCount or 0
end

function LeadIntoAidModel:GetAidCount()
    local maxAidCount = self:GetMaxAidCount()
    local beAidCount = self:GetBeAidCount()
    local aidCount = maxAidCount - beAidCount
    if aidCount < 0 then aidCount = 0 end
    return aidCount
end

function LeadIntoAidModel:GetRefreshCost()
    local base = self.data.mystery.base
    return base and base.refreshCost or 0
end

function LeadIntoAidModel:GetAidCards()
    local cards = self.data.mystery.m_cards
    return cards or {}
end

function LeadIntoAidModel:SetBeAidCount(beAidCount)
    self.data.mystery.base.m_r_cnt = beAidCount
end

function LeadIntoAidModel:UpdateMystery(mystery)
    self.data.mystery = mystery
end

-- "buy": 0 --未购买，1：已购买
function LeadIntoAidModel:HasCardBuy(index)
    local cards = self:GetAidCards()
    local cardData = cards[index]
    local buyState = cardData and cardData.buy
    if buyState == 0 then 
        return false
    elseif buyState == 1 then
        return true
    end
    return false
end

function LeadIntoAidModel:HasAidCount()
    local aidCount = self:GetAidCount()
    return tobool(aidCount > 0)
end

return LeadIntoAidModel