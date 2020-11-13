local GeneralDialogCtrl = require("ui.controllers.greensward.dialog.GeneralDialogCtrl")
local SubwayDialogCtrl = class(GeneralDialogCtrl, "SubwayDialogCtrl")

SubwayDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/GeneralDialog.prefab"

SubwayDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function SubwayDialogCtrl:Init(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    self.view:InitView(eventModel,greenswardResourceCache)
    self.view.moraleClick = function() self:MoraleClick() end
    self.view.powerClick = function() self:PowerClick() end
end

function SubwayDialogCtrl:TriggerPost(costType)
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row = self.eventModel:GetRow()
            local col = self.eventModel:GetCol()
            local respone = req.greenswardAdventureSubway(row, col)
            if api.success(respone) then
                local data = respone.val
                local base = data.base or { }
                local map = data.ret and data.ret.map or { }
                local cellResult = data.ret and data.ret.cellResult or { }
                local buildModel = self.eventModel:GetBuildModel()
                buildModel:RefreshBaseInfo(base)
                self.eventModel:HandleEvent(data)
                self.view:Close()
            end
        end)
    end
end

return SubwayDialogCtrl