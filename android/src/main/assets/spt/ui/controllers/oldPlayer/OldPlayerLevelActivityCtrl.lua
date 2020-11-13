local OldPlayerContentBaseCtrl = require("ui.controllers.oldPlayer.OldPlayerContentBaseCtrl")
local OldPlayerLevelActivityCtrl = class(OldPlayerContentBaseCtrl)

function OldPlayerLevelActivityCtrl:ctor(parentContent, oldPlayerModel)
    self.oldPlayerModel = oldPlayerModel
    OldPlayerLevelActivityCtrl.super.ctor(self, parentContent, "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerVerticalCommonBoard.prefab")
end

function OldPlayerLevelActivityCtrl:SpreadButtonReg()
    self.view.onRecv = function(recvData, reqCallBack) self:OnRecv(recvData, reqCallBack) end
end

local ItemPath = "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerLevelActivityItem.prefab"
function OldPlayerLevelActivityCtrl:InitView()
    self.view:InitView(self.oldPlayerModel:GetCurrContentData(), ItemPath)
end

function OldPlayerLevelActivityCtrl:OnEnterScene()
end

function OldPlayerLevelActivityCtrl:OnExitScene()

end

return OldPlayerLevelActivityCtrl
