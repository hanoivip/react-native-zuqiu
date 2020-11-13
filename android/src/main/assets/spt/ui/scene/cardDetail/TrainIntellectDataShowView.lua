local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TrainIntellectDataShowView = class(unity.base)

function TrainIntellectDataShowView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.trainNum = self.___ex.trainNum
    self.saveNum = self.___ex.saveNum
    self.potentNum = self.___ex.potentNum
    self.attrMap = self.___ex.attrMap
    self.attrValueMap = self.___ex.attrValueMap
    self.powerNum = self.___ex.powerNum
end

function TrainIntellectDataShowView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:Close()
    end)

    DialogAnimation.Appear(self.transform)
end

function TrainIntellectDataShowView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

local function GetValue(oldValue, newValue)
    local value = oldValue
    if newValue > oldValue then 
        local add = newValue - oldValue
        value = value .. "<color=#9CDC14>(+" .. add  .. ")</color>"
    elseif newValue < oldValue then 
        local sub = oldValue - newValue
        value = value .. "<color=red>(-" .. sub .. ")</color>"
    end
    return tostring(value)
end

function TrainIntellectDataShowView:InitView(oldCardModel, newCardModel, costVitaminNum, saveNum)
    self.trainNum.text = lang.trans("train_count", costVitaminNum)
    self.saveNum.text = lang.trans("save_count", saveNum)
    local oldPotent = oldCardModel:GetStaticPotential() - oldCardModel:GetConsumePotent() + oldCardModel:GetLegendPotentImprove()
    local newPotent = newCardModel:GetStaticPotential() - newCardModel:GetConsumePotent() + newCardModel:GetLegendPotentImprove()
    self.potentNum.text = GetValue(oldPotent, newPotent)

    if oldCardModel:IsGKPlayer() then
        pentagonOrder = CardHelper.GoalKeeperOrder
    else
        pentagonOrder = CardHelper.NormalPlayerOrder
    end
    for i, abilityIndex in ipairs(pentagonOrder) do
        local base, plus, train = oldCardModel:GetAbility(abilityIndex)
        local base2, plus2, train2 = newCardModel:GetAbility(abilityIndex)
        self.attrMap["s" .. tostring(i)].text = lang.transstr(abilityIndex) .. ":"
        self.attrValueMap["s" .. tostring(i)].text = GetValue(train, train2)
    end
    self.powerNum.text = lang.trans("power_change", GetValue(oldCardModel:GetPower(), newCardModel:GetPower()))
end

return TrainIntellectDataShowView