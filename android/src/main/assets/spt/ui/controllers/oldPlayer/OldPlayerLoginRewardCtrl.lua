local OldPlayerContentBaseCtrl = require("ui.controllers.oldPlayer.OldPlayerContentBaseCtrl")
local OldPlayerLoginRewardCtrl = class(OldPlayerContentBaseCtrl)

function OldPlayerLoginRewardCtrl:ctor(parentContent, oldPlayerModel)
    self.oldPlayerModel = oldPlayerModel
    OldPlayerLoginRewardCtrl.super.ctor(self, parentContent, "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerVerticalCommonBoard.prefab")
end

function OldPlayerLoginRewardCtrl:SpreadButtonReg()
    self.view.onRecv = function(recvData, reqCallBack) self:OnRecv(recvData, reqCallBack) end
end

local ItemPath = "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerLoginRewardItem.prefab"
function OldPlayerLoginRewardCtrl:InitView()
    self.view:InitView(self.oldPlayerModel:GetCurrContentData(), ItemPath)
end

function OldPlayerLoginRewardCtrl:OnEnterScene()
end

function OldPlayerLoginRewardCtrl:OnExitScene()

end

return OldPlayerLoginRewardCtrl
