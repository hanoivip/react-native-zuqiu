local OldPlayerContentBaseCtrl = require("ui.controllers.oldPlayer.OldPlayerContentBaseCtrl")
local OldPlayerRechargeActivityCtrl = class(OldPlayerContentBaseCtrl)

function OldPlayerRechargeActivityCtrl:ctor(parentContent, oldPlayerModel)
    self.oldPlayerModel = oldPlayerModel
    OldPlayerRechargeActivityCtrl.super.ctor(self, parentContent, "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerVerticalCommonBoard.prefab")
end

function OldPlayerRechargeActivityCtrl:SpreadButtonReg()
    self.view.onRecv = function(recvData, reqCallBack) self:OnRecv(recvData, reqCallBack) end
end

local ItemPath = "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerRechargeActivityItem.prefab"
function OldPlayerRechargeActivityCtrl:InitView()
    self.view:InitView(self.oldPlayerModel:GetCurrContentData(), ItemPath)
end

function OldPlayerRechargeActivityCtrl:OnEnterScene()
end

function OldPlayerRechargeActivityCtrl:OnExitScene()

end

return OldPlayerRechargeActivityCtrl