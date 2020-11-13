local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local CardBuilder = require("ui.common.card.CardBuilder")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local TimeLimitLeagueLetterCtrl = class(ActivityContentBaseCtrl, "TimeLimitLeagueLetterCtrl")

function TimeLimitLeagueLetterCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.onBtnReceive = function() self:OnBtnReceive() end
    self.view.onClickBigCard = function(cid) self:OnClickBigCard(cid) end

    self.view:InitView(self.activityModel)
end

function TimeLimitLeagueLetterCtrl:OnRefresh()
end

function TimeLimitLeagueLetterCtrl:OnBtnReceive()
    local activityType = self.activityModel:GetActivityType()
    local subId = self.activityModel:GetSubId()
    clr.coroutine(function()
        local response = req.activityTimeLimitChallengeReceiveReward(activityType, subId)
        if api.success(response) then
            local data = response.val
            if next(data) then
                CongratulationsPageCtrl.new(data.contents)
                self.activityModel:UpdateDataAfterReceive(data.activity)
                self.view:UpdateAfterReceive()
            end
        end
    end)
end

function TimeLimitLeagueLetterCtrl:OnClickBigCard(cid)
    local currentModel = CardBuilder.GetBaseCardModel(cid)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
end

function TimeLimitLeagueLetterCtrl:OnClickCard(cid)
    local playerCardsMapModel = PlayerCardsMapModel.new()
    local isOwnCard = playerCardsMapModel:IsExistCardID(cid)
    local currentModel
    if isOwnCard then
        local pcId = playerCardsMapModel:GetPcidByCid(cid)
        currentModel = CardBuilder.GetOwnCardModel(pcId)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {pcId}, 1, currentModel)
    else
        currentModel = CardBuilder.GetBaseCardModel(cid)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
    end
end

function TimeLimitLeagueLetterCtrl:OnEnterScene()
    EventSystem.AddEvent("ActivityPlayerLetter.ReplyLetter", self, self.ReplyLetter)
    EventSystem.AddEvent("ActivityPlayerLetterDetail.ShowCardDetail", self, self.OnClickCard)
end

function TimeLimitLeagueLetterCtrl:OnExitScene()
    EventSystem.RemoveEvent("ActivityPlayerLetter.ReplyLetter", self, self.ReplyLetter)
    EventSystem.RemoveEvent("ActivityPlayerLetterDetail.ShowCardDetail", self, self.OnClickCard)
end

return TimeLimitLeagueLetterCtrl

