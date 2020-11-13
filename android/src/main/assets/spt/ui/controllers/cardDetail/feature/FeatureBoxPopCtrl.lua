local FeatureBoxPopCtrl = class()

function FeatureBoxPopCtrl:ctor(skillModel, oldSkill)
    local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeaturePopBoard.prefab", "camera", true, true)
    dialogcomp.contentcomp:InitView(skillModel, oldSkill)
    dialogcomp.contentcomp.clickConfirm = function() self:OnEnd(dialogcomp.contentcomp) end
end

function FeatureBoxPopCtrl:OnEnd(view)
    view:Close()
end

return FeatureBoxPopCtrl

