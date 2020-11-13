local TipUpgradeCtrl = class()

function TipUpgradeCtrl:ctor(cardDetailModel)
    local viewObject, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/TipUpgrade.prefab", "camera", false, true)
    self.tipUpgradeView = dialogcomp.contentcomp
    self.tipUpgradeView:InitView(cardDetailModel)
end

return TipUpgradeCtrl
