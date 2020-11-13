local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local EnergyDrinkDialogCtrl = class(BaseCtrl, "EnergyDrinkDialogCtrl")

EnergyDrinkDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/EnergyDrink/EnergyDrinkDialog.prefab"

function EnergyDrinkDialogCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view:InitView(eventModel)
    self.view.onStartClick = function() self:StartClick() end
end

function EnergyDrinkDialogCtrl:StartClick()
    local drinkBuff = self.eventModel:GetDrinkBuff()
    local roundLeft = self.eventModel:GetRoundLeft()
    local buffRoundLeft = self.eventModel:GetDrinkBuffRoundLeft()
    local count = self.eventModel:GetConsumeMorale()
    local cycleRound = self.eventModel:GetCycleRound()
    local nextRound = roundLeft - 1
    local contentMessage, costMes
    if nextRound == 0 then
        costMes = lang.transstr("adventure_energy_main", count, cycleRound)
    else
        costMes = lang.transstr("adventure_energy_main", count, nextRound)
    end
    if roundLeft <= 1 then
        contentMessage = lang.transstr("adventure_energy_new", cycleRound)
        contentMessage = costMes .. contentMessage
    else
        local remainMes = lang.transstr("adventure_energy_remain", nextRound)
        if next(drinkBuff) then
            local buffNum = drinkBuff.buff
            local buffName = lang.transstr("allAttribute")
            if buffNum > 0 then
                buffName = buffName .. "+" .. buffNum .. "%"
            else
                buffNum = math.abs(buffNum)
                buffName = buffName .. "-" .. buffNum .. "%"
            end
            contentMessage = lang.transstr("adventure_energy_replace", buffRoundLeft, buffName, costMes .. remainMes)
        else
            contentMessage = costMes .. remainMes
        end
    end
    local title = lang.trans("tips")
    DialogManager.ShowConfirmPop(title, contentMessage, function() self:Buy() end)
end

function EnergyDrinkDialogCtrl:Buy()
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row = self.eventModel:GetRow()
            local col = self.eventModel:GetCol()
            local respone = req.greenswardAdventureTrigger(row, col)
            if api.success(respone) then
                local data = respone.val
                local base = data.base or { }
                local map = data.ret and data.ret.map or { }
                self.eventModel:SetDrinkBuff(data.base.buff.drink)
                local buildModel = self.eventModel:GetBuildModel()
                self.view.closeDialog()
                buildModel:RefreshEventData(map)
                buildModel:RefreshBaseInfo(base)
                self.eventModel:HandleEvent(data)
                self:ShowRewardEffect()
            end
        end)
    end
end

function EnergyDrinkDialogCtrl:ShowRewardEffect()
    local rewardViewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/EnergyDrink/EnergyDrinkRewardView.prefab"
    local dialog, dialogcomp = res.ShowDialog(rewardViewPath, "camera", false, true)
    dialogcomp.contentcomp:InitView(self.eventModel)
end

return EnergyDrinkDialogCtrl
