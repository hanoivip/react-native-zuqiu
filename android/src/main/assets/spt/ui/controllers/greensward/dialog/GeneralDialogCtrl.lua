local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GreenswardItemActionMainCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionMainCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local GeneralDialogCtrl = class(BaseCtrl, "GeneralDialogCtrl")

GeneralDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/GeneralDialog.prefab"

GeneralDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function GeneralDialogCtrl:Init(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    self.view:InitView(eventModel, greenswardResourceCache)
    self.view.moraleClick = function() self:MoraleClick() end
    self.view.powerClick = function() self:PowerClick() end
    self.view.itemClick = function(hasItem) self:ItemClick(hasItem) end
end

function GeneralDialogCtrl:MoraleClick()
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self:TriggerPost("morale")
    end
end

function GeneralDialogCtrl:PowerClick()
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self:TriggerPost("fight")
    end
end

function GeneralDialogCtrl:TriggerPost(costType)
    self.view:coroutine(function()
        local row = self.eventModel:GetRow()
        local col = self.eventModel:GetCol()
        local respone = req.greenswardAdventureTrigger(row, col, costType)
        if api.success(respone) then
            local data = respone.val
            local base = data.base or { }
            local map = data.ret and data.ret.map or { }
			local cellResult = data.ret and data.ret.cellResult or { }
            local buildModel = self.eventModel:GetBuildModel()
            buildModel:RefreshEventData(map)
            buildModel:RefreshBaseInfo(base)
            self.eventModel:HandleEvent(data)
            self.view:Close()
            local tip = self.eventModel:GetTip()
			if next(cellResult) then 
				CongratulationsPageCtrl.new(cellResult.contents)
            elseif tip and tip ~= "" then
                DialogManager.ShowToast(lang.trans(tip))
			end

            local passTip = self.eventModel:GetPassTip()
            if passTip and passTip ~= "" then
                DialogManager.ShowToast(lang.trans(passTip))
            end
        end
    end)
end

-- 使用道具通过
function GeneralDialogCtrl:ItemClick(hasItem)
    if hasItem then
        local itemModel = self.eventModel:GetConsumeItemModel()
        local row = self.eventModel:GetRow()
        local col = self.eventModel:GetCol()

        if not itemModel then return end

        local actionMainCtrl = GreenswardItemActionMainCtrl.new(itemModel, self.eventModel:GetBuildModel(), self.eventModel)
        actionMainCtrl:DoAction()
    else
        DialogManager.ShowToast(self.eventModel:GetUseItemTip())
    end
end

function GeneralDialogCtrl:OnExitScene()
    self.view:ExitScene()
end

return GeneralDialogCtrl
