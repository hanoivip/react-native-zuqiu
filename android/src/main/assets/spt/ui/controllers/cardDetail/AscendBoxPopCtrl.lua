local AscendBoxPopCtrl = class()

function AscendBoxPopCtrl:ctor(oldCardModel, newCardModel)
    local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/AscendPopBoard.prefab", "camera", false, true)
    dialogcomp.contentcomp:InitView(oldCardModel, newCardModel)
    dialogcomp.contentcomp.clickConfirm = function() self:OnEnd(dialogcomp.contentcomp) end
end

function AscendBoxPopCtrl:OnEnd(view)
    view:Close()
end

return AscendBoxPopCtrl
