local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local PlaneDialogCtrl = class(BaseCtrl, "PlaneDialogCtrl")

PlaneDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/PlaneDialog.prefab"

PlaneDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PlaneDialogCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view:InitView(eventModel)
    self.view.flyClick = function() self:FlyClick() end
end

function PlaneDialogCtrl:FlyClick()
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local respone = req.greenswardAdventurePassNextFloor()
            if api.success(respone) then
                local data = respone.val
                local base = data.base or { }
                local map = data.ret and data.ret.map or { }
                local buildModel = self.eventModel:GetBuildModel()
                buildModel:RefreshBaseInfo(base)
                buildModel:RefreshEventModel(map)
                local row, col = buildModel:GetJumpGirdNumber()
                EventSystem.SendEvent("GreenswardMoveConstruction", row, col)
                EventSystem.SendEvent("GreenswardPlaneEffectShow", false)
                self.view:Close()
                local contents = data.ret and data.ret.contents or {}
                if not table.isEmpty(contents) then
                    res.PushDialog("ui.controllers.greensward.prop.MysticHintRcvDialogCtrl", buildModel, contents)
                else
                    local currentFloor = buildModel:GetCurrentFloor()
                    GuideManager.InitCurModule("adventureF" .. currentFloor)
                    GuideManager.Show(self)
                end
            end
        end)
    end
end

return PlaneDialogCtrl