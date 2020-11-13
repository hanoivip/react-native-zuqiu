local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local TimeLimitLetterCtrl = class(ActivityContentBaseCtrl)

function TimeLimitLetterCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
end

function TimeLimitLetterCtrl:OnRefresh()
end

function TimeLimitLetterCtrl:ReplyLetter(letterIndex)
    local activityPlayerLetterModel = self.activityModel
    local activityType = activityPlayerLetterModel:GetActivityType()
    clr.coroutine(function()
        local response = req.activityTimeLimitChallengeReceiveReward(activityType, activityPlayerLetterModel:GetSubIdByIndex(letterIndex))
        if api.success(response) then
            local data = response.val
            if next(data) then
                CongratulationsPageCtrl.new(data.contents)   
                self.view.scrollView:UpdateRewardStates(letterIndex)
                EventSystem.SendEvent("ActivityPlayerLetterDetailView.BuildReplyBtn", 1)
                self.view:InitView(self.activityModel)
            end
        end
    end)
end

function TimeLimitLetterCtrl:OnEnterScene()
    EventSystem.AddEvent("ActivityPlayerLetter.ReplyLetter", self, self.ReplyLetter)
    self.view:OnEnterScene()
end

function TimeLimitLetterCtrl:OnExitScene()
    EventSystem.RemoveEvent("ActivityPlayerLetter.ReplyLetter", self, self.ReplyLetter)
    self.view:OnExitScene()
end

return TimeLimitLetterCtrl

