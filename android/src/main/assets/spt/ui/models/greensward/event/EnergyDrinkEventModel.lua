local AdventureFloor = require("data.AdventureFloor")
local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local EnergyDrinkEventModel = class(GeneralEventModel, "EnergyDrinkEventModel")

function EnergyDrinkEventModel:ctor()
    EnergyDrinkEventModel.super.ctor(self)
end

function EnergyDrinkEventModel:GetEnergyDrinkEffectDisplay()
    local display = {}
    local curFloor = self.buildModel:GetCurrentFloor()
    curFloor = tostring(curFloor)
    -- 能量饮料Buff效果(百分之一；增益值=权重#减益值=权重)
    local drinkBuff = AdventureFloor[curFloor].drinkBuff
    for k, v in pairs(drinkBuff) do
        table.insert(display, k)
    end
    return display
end

-- 当前饮料buff的剩余回合
function EnergyDrinkEventModel:GetDrinkBuffRoundLeft()
    local buffData = self:GetDrinkBuff()
    return buffData.round or 0
end

-- 当前buff数据
function EnergyDrinkEventModel:GetDrinkBuff()
    local buffData = self.buildModel:GetDrinkBuff()
    return buffData
end

-- 使用饮料后更新数据
function EnergyDrinkEventModel:SetDrinkBuff(buffData)
    self.buildModel:SetDrinkBuff(buffData)
end

-- 几回合切换周期
function EnergyDrinkEventModel:GetCycleRound()
    local cycleRound = self.buildModel:GetCycleRound()
    return cycleRound
end

-- 获得当前周期剩余回合
function EnergyDrinkEventModel:GetRoundLeft()
    local roundLeft = self.buildModel:GetRoundLeft()
    return roundLeft
end

function EnergyDrinkEventModel:GetBottomBoardName()
    return "Drink_Dlog"
end

function EnergyDrinkEventModel:HasTweenExtension()
    return true
end

return EnergyDrinkEventModel
