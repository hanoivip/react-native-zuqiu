local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local ActivityPlayerLetterDetailCtrl = class(BaseCtrl)
ActivityPlayerLetterDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/ActivityPlayerLetterDetail.prefab"

function ActivityPlayerLetterDetailCtrl:Refresh(curTag, letterIndex, activityplayerLetterDetailViewModel)
    self.curTag = curTag
    self.letterIndex = letterIndex
    self.activityplayerLetterDetailViewModel = activityplayerLetterDetailViewModel
    self.activityplayerLetterDetailViewModel:SetSelectedTabTag(curTag)
    self:RegisterEvent()
    self:RefreshView()   
end

function ActivityPlayerLetterDetailCtrl:RefreshView()
    EventSystem.SendEvent("ActivityPlayerLetterDetailView.InitView", self.activityplayerLetterDetailViewModel, self.letterIndex )
    local loadType = self:GetLoadType()
    if loadType ~= res.LoadType.Pop then
        self.view:PlayMoveInAnim()
    end
    EventSystem.SendEvent("ActivityPlayerLetterDetailView.OnEnterView")
end

function ActivityPlayerLetterDetailCtrl:RefreshModel(activityplayerLetterDetailViewModel)
    self:Refresh(self.curTag, self.letterIndex, activityplayerLetterDetailViewModel)
end

function ActivityPlayerLetterDetailCtrl:RegisterEvent()
    EventSystem.AddEvent("ActivityPlayerLetterDetail.ShowCardDetail", self, self.ShowCardDetail)
    EventSystem.AddEvent("ActivityPlayerLetterDetail.Refresh", self, self.RefreshView)
    EventSystem.AddEvent("ActivityPlayerLetterDetail.RefreshModel", self, self.RefreshModel)
end

function ActivityPlayerLetterDetailCtrl:RemoveEvent()
    EventSystem.RemoveEvent("ActivityPlayerLetterDetail.ShowCardDetail", self, self.ShowCardDetail)
    EventSystem.RemoveEvent("ActivityPlayerLetterDetail.Refresh", self, self.RefreshView)
    EventSystem.RemoveEvent("ActivityPlayerLetterDetail.RefreshModel", self, self.RefreshModel)
end

--- 显示大卡
function ActivityPlayerLetterDetailCtrl:ShowCardDetail(cardStaticID)
    local playerCardsMapModel = PlayerCardsMapModel.new()
    local isOwnCard = playerCardsMapModel:IsExistCardID(cardStaticID)
    local currentModel
    if isOwnCard then
        local pcId = playerCardsMapModel:GetPcidByCid(cardStaticID)
        currentModel = CardBuilder.GetOwnCardModel(pcId)
        -- 需要禁止进入生涯时候解开
        -- currentModel.IsAllowChangeScene = function() return false end
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {pcId}, 1, currentModel)
    else
        currentModel = CardBuilder.GetBaseCardModel(cardStaticID)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cardStaticID}, 1, currentModel)
    end
end

function ActivityPlayerLetterDetailCtrl:GetStatusData()
    return self.curTag, self.letterIndex, self.activityplayerLetterDetailViewModel
end

function ActivityPlayerLetterDetailCtrl:OnExitScene()
    EventSystem.SendEvent("PlayerLetterDetail.OnExitView")
    self:RemoveEvent()
    self.waitToShowDialog = true
end

return ActivityPlayerLetterDetailCtrl