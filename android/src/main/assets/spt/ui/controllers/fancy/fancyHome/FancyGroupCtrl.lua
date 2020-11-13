local BaseCtrl = require("ui.controllers.BaseCtrl")
local FancyGroupCtrl = class(BaseCtrl, "FancyGroupCtrl")
local FancyGroupModel = require("ui.models.fancy.fancyHome.FancyGroupModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
FancyGroupCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyHome/FancyGroup.prefab"

function FancyGroupCtrl:Refresh(groupID, fancyCardMapsModel)
    FancyGroupCtrl.super.Refresh(self)
    self.groupID = groupID
	self.fancyGroupModel = FancyGroupModel.new()
	self.fancyCardMapsModel = fancyCardMapsModel
	self.fancyGroupModel:InitData(groupID, fancyCardMapsModel)
    self:InitView()
    GuideManager.Show(self)
end

function FancyGroupCtrl:InitView()
    self.view:InitView(self.fancyGroupModel)
    self.view.onCardClick = function(index) self:OnCardClick(index) end
end

function FancyGroupCtrl:OnCardClick(index)
	local card = self.fancyGroupModel:GetCard(index)
    local info = card:GetFancyInfo()
    if info then
        res.PushDialogImmediate("ui.controllers.fancy.fancyHome.FancyStarUpCtrl", card)
    else
        res.PushDialogImmediate("ui.controllers.fancy.fancyHome.FancyPreviewCtrl", 2, card)
    end
end

function FancyGroupCtrl:OnEnterScene()
    self.view:EnterScene()
end

function FancyGroupCtrl:OnExitScene()
    self.view:ExitScene()
end

function FancyGroupCtrl:GetStatusData()
    return self.groupID, self.fancyCardMapsModel
end

return FancyGroupCtrl