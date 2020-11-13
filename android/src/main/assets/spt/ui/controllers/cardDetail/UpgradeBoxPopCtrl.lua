local UpgradeBoxPopCtrl = class()

function UpgradeBoxPopCtrl:ctor(cardModel, upgrade)
    local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/UpgradePopBoard.prefab", "camera", true, true)
    dialogcomp.contentcomp:InitView(cardModel, upgrade)
    dialogcomp.contentcomp.clickConfirm = function() self:OnEnd(dialogcomp.contentcomp) end
end

function UpgradeBoxPopCtrl:OnEnd(view)
    view:Close()
end

return UpgradeBoxPopCtrl

