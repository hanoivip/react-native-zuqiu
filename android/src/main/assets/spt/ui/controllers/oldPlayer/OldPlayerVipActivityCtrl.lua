local OldPlayerContentBaseCtrl = require("ui.controllers.oldPlayer.OldPlayerContentBaseCtrl")
local OldPlayerVipActivityCtrl = class(OldPlayerContentBaseCtrl)

function OldPlayerVipActivityCtrl:ctor(parentContent, oldPlayerModel)
    self.oldPlayerModel = oldPlayerModel
    OldPlayerVipActivityCtrl.super.ctor(self, parentContent, "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerVerticalCommonBoard.prefab")
end

function OldPlayerVipActivityCtrl:SpreadButtonReg()
    self.view.onRecv = function(recvData, reqCallBack) self:OnRecv(recvData, reqCallBack) end
end

local ItemPath = "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerVipActivityItem.prefab"
function OldPlayerVipActivityCtrl:InitView()
    self.view:InitView(self.oldPlayerModel:GetCurrContentData(), ItemPath)
end

function OldPlayerVipActivityCtrl:OnEnterScene()
end

function OldPlayerVipActivityCtrl:OnExitScene()

end

return OldPlayerVipActivityCtrl
