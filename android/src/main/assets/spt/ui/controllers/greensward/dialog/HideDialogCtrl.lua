local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GeneralDialogCtrl = require("ui.controllers.greensward.dialog.GeneralDialogCtrl")
local GreenswardEvnetEnum = require("ui.scene.greensward.GreenswardEvnetEnum")
local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardItemActionMainCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionMainCtrl")

local HideDialogCtrl = class(GeneralDialogCtrl, "HideDialogCtrl")

HideDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/GeneralDialog.prefab"

HideDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function HideDialogCtrl:Init(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    self.view:InitView(eventModel,greenswardResourceCache)
    self.view.moraleClick = function() self:MoraleClick() end
    self.view.powerClick = function() self:PowerClick() end
    self.view.itemClick = function() self:ItemClick() end
end

function HideDialogCtrl:TriggerPost(costType)
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row = self.eventModel:GetRow()
            local col = self.eventModel:GetCol()
            local respone = req.greenswardAdventureTreasureOpen(row, col, costType)
            if api.success(respone) then
                local data = respone.val
                local base = data.base or { }
                local map = data.ret and data.ret.map or { }
                local cellResult = data.ret and data.ret.cellResult or { }
                local key = tostring(row) .. "_" .. tostring(col)
                local buildModel = self.eventModel:GetBuildModel()
                buildModel:RefreshBaseInfo(base)
                buildModel:RefreshEventModel(map)
                self.view:Close()
                local newType = map[tostring(key)] and map[tostring(key)].type
                local tip = self.eventModel:GetTip()
                if next(cellResult) then
                    CongratulationsPageCtrl.new(cellResult.contents)
                    DialogManager.ShowToast(lang.trans("adventure_dig_tip"))
                elseif tonumber(newType) == GreenswardEvnetEnum.Detecting1 then
                    DialogManager.ShowToast(lang.trans(tip))
                end
            end
        end)
    end
end

-- 使用道具通过
function GeneralDialogCtrl:ItemClick()
    local itemModel = self.eventModel:GetConsumeItemModel()
    local row = self.eventModel:GetRow()
    local col = self.eventModel:GetCol()

    if not itemModel then return end

    local actionMainCtrl = GreenswardItemActionMainCtrl.new(itemModel, self.eventModel:GetBuildModel(), self.eventModel)
    actionMainCtrl:DoAction()
end

function GeneralDialogCtrl:OnExitScene()
    self.view:ExitScene()
end

return HideDialogCtrl
