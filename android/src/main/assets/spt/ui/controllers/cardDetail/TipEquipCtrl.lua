local TipEquipCtrl = class()

function TipEquipCtrl:ctor(itemDetailModel)
    local viewObject, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/TipEquip.prefab", "camera", false, true)
    self.tipEquipView = dialogcomp.contentcomp
    self.tipEquipView:InitView(itemDetailModel)
end

return TipEquipCtrl
