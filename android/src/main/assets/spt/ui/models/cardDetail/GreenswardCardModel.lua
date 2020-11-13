local OtherCardModel = require("ui.models.cardDetail.OtherCardModel")
local GreenswardCardModel = class(OtherCardModel)

function GreenswardCardModel:SetOpponentEventRatio(opRevise)
    self.opRevise = opRevise
end

function GreenswardCardModel:GetOpponentEventRatio()
    return self.opRevise or 1
end

function GreenswardCardModel:GetPower(medalCombine)
    local power = GreenswardCardModel.super.GetPower(self, medalCombine)
    local opRevise = self:GetOpponentEventRatio()
    power = math.floor(power * opRevise)
    return power
end

function GreenswardCardModel:GetGreenswardAbility(index)
    local greenswardPlus = 0
    if self.cacheData.balanceAttr then
        greenswardPlus = self.cacheData.balanceAttr[index] or 0
    end
    return greenswardPlus
end

function GreenswardCardModel:GetBaseAbility(index)
    local staticNum = self.staticData[index]
    local greenswardPlus = self:GetGreenswardAbility(index)
    staticNum = staticNum + greenswardPlus
    return staticNum
end

function GreenswardCardModel:GetAbility(index, medalCombine)
    local opRevise = self:GetOpponentEventRatio()
    local baseNum, plusNum, trainNum, totalNum = GreenswardCardModel.super.GetAbility(self, index, medalCombine)
    baseNum = math.floor(baseNum * opRevise)
    plusNum = math.floor(plusNum * opRevise)
    trainNum = math.floor(trainNum * opRevise)
    totalNum = math.floor(totalNum * opRevise)
    return baseNum, plusNum, trainNum, totalNum
end

return GreenswardCardModel