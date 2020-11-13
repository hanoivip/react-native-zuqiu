local FeatureBoxReplacePopCtrl = class()

function FeatureBoxReplacePopCtrl:ctor(skillModel, oldSkill, pcid, skillBookId, itemId)
    local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureReplace.prefab", "camera", false, true)
    dialogcomp.contentcomp:InitView(skillModel, oldSkill, pcid, skillBookId, itemId)
	dialogcomp.contentcomp.clickCancel = function() self:ClickCancel(dialogcomp.contentcomp) end
    dialogcomp.contentcomp.clickConfirm = function(skillModel, oldSkill, pcid, skillBookId, itemId) self:ClickConfirm(dialogcomp.contentcomp, skillModel, oldSkill, pcid, skillBookId, itemId) end
end

function FeatureBoxReplacePopCtrl:ClickCancel(view)
	EventSystem.SendEvent("CardFeature_ChooseCancel")
    view:Close()
end

function FeatureBoxReplacePopCtrl:ClickConfirm(view, skillModel, oldSkill, pcid, skillBookId, itemId)
	EventSystem.SendEvent("CardFeature_ChooseConfirm", skillModel, oldSkill, pcid, skillBookId, itemId)
    view:Close()
end

return FeatureBoxReplacePopCtrl

