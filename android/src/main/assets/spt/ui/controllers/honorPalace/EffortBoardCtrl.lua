local BaseCtrl = require("ui.controllers.BaseCtrl")
local EffortBoardModel = require("ui.models.honorPalace.EffortBoardModel")
local EffortBoardCtrl = class(BaseCtrl)

EffortBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/HonorPalace/EffortBoard.prefab"

EffortBoardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function EffortBoardCtrl:AheadRequest()
    local respone = req.rankTop()
    if api.success(respone) then
        local data = respone.val
        self.effortModel = EffortBoardModel.new()
        self.effortModel:InitWithProtocol(data)
    end
end

function EffortBoardCtrl:Init()
    self:InitView(self.effortModel)
end

function EffortBoardCtrl:InitView(model)
    self.view:InitView(model)
end

return EffortBoardCtrl