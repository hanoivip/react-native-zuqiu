local BaseCtrl = require("ui.controllers.BaseCtrl")
local SearchDlgCtrl = class(BaseCtrl)
SearchDlgCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerList/SearchBox.prefab"
SearchDlgCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}
function SearchDlgCtrl:Init(cardIndexSearchModel)
    self.cardIndexSearchModel = cardIndexSearchModel
    self.view.searchFunc = function() self:Search() end
    self.view.openSkillBoard = function() self:OpenSkillBoard() end
    self.view:InitView(cardIndexSearchModel)
end

function SearchDlgCtrl:Search()
    self.cardIndexSearchModel:SetName(self.view.playerNameInput.text)
    self.cardIndexSearchModel:SetQuality(self.view.quality)
    self.cardIndexSearchModel:SetPos(self.view.selectPos)
    self.cardIndexSearchModel:SetNationality(self.view:GetNationalityFieldText())
    EventSystem.SendEvent("CardIndex.SearchSpecificPlayers")
    self.view.closeDialog()
end

function SearchDlgCtrl:OpenSkillBoard()
    res.PushDialog("ui.controllers.cardIndex.SelectSkillsDlgCtrl", self.cardIndexSearchModel)
end

return SearchDlgCtrl