local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local GreenswardMoraleRecieveDialogCtrl = class(BaseCtrl, "GreenswardMoraleRecieveDialogCtrl")

GreenswardMoraleRecieveDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/MoraleRecieve.prefab"

GreenswardMoraleRecieveDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardMoraleRecieveDialogCtrl:Init(buildModel)
    self.buildModel = buildModel
    self.view:InitView(buildModel)
    self.view.onMoraleRecieveClick = function() self:MoraleRecieveClick() end
end

function GreenswardMoraleRecieveDialogCtrl:MoraleRecieveClick()
    self.view:coroutine(function()
        local respone = req.greenswardAdventureMoraleDailyRecieve()
        if api.success(respone) then
            local data = respone.val
            self.buildModel:RetMoraleRecieveStatus()
            local content = data.ret and data.ret.contents or {}
            if next(content) then
                CongratulationsPageCtrl.new(content)
                self.buildModel:AddMoraleNum(content.morale)
            else
                DialogManager.ShowToast(lang.trans("recieve_timeOver"))
            end
            local base = data.base or {}
            self.buildModel:RefreshBaseInfo(base)
            self.view:Close()
        end
    end)
end

return GreenswardMoraleRecieveDialogCtrl