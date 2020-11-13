local MatchLoader = require("coregame.MatchLoader")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local QuestionsStartDialogCtrl = class(BaseCtrl, "LotteryDialogCtrl")

QuestionsStartDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Questions/QuestionsStartDialog.prefab"

function QuestionsStartDialogCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view:InitView(eventModel)
    self.view.answerReward = function() self:AnswerReward() end
end

function QuestionsStartDialogCtrl:AnswerReward()
    self.view:coroutine(function()
        local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
        local response = req.greenswardAdventureAnswerReward(row, col)
        if api.success(response) then
            local data = response.val
            local ret = data.ret or {}
            CongratulationsPageCtrl.new(ret.contents)
            self.view:closeDialog()
        end
    end)
end

return QuestionsStartDialogCtrl