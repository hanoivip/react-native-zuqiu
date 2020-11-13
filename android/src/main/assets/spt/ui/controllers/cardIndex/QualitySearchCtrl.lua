local QualitySearchCtrl = class()

function QualitySearchCtrl:ctor()
    local searchDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardIndex/QualitySearchBoard.prefab", "camera", false, true)
    self.searchView = dialogcomp.contentcomp

    self.searchView.clickConfirm = function(qualityIndex) self:OnBtnConfirm(qualityIndex) end
end

function QualitySearchCtrl:InitView(cardIndexViewModel)
    self.cardIndexViewModel = cardIndexViewModel
    self.searchView:InitView(cardIndexViewModel)
end

function QualitySearchCtrl:OnBtnConfirm(qualityIndex)
    EventSystem.SendEvent("CardIndex.ShowSpecificQualityPlayers", qualityIndex)
end

return QualitySearchCtrl
