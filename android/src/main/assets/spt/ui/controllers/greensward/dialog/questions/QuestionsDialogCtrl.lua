local BaseCtrl = require("ui.controllers.BaseCtrl")
local QuestionsDialogCtrl = class(BaseCtrl, "LotteryDialogCtrl")

QuestionsDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Questions/QuestionsDialog.prefab"


function QuestionsDialogCtrl:AheadRequest(eventModel)
    self.eventModel = eventModel
    local row, col = eventModel:GetRow(), eventModel:GetCol()
    local response = req.greenswardAdventureViewCell(row, col)
    if api.success(response) then
    	local data = response.val
        eventModel:InitWithProtocolReward(data)
    end
end

function QuestionsDialogCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view:InitView(eventModel)
    self.view.onStartClick = function() self:StartClick() end
end

function QuestionsDialogCtrl:StartClick()
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
            local response = req.greenswardAdventureTrigger(row, col)
            if api.success(response) then
                local data = response.val
                local base = data.base or {}
                local ret = data.ret or {}
                local question = ret.question or {}
                local map = ret.map or {}
                local buildModel = self.eventModel:GetBuildModel()
                buildModel:RefreshEventData(map)
                buildModel:RefreshBaseInfo(base)
                self.eventModel:HandleEvent(data)
                self.eventModel:InitWithProtocolQuestion(question)
                self.view.closeDialog()
                res.PushDialog("ui.controllers.greensward.dialog.questions.QuestionsStartDialogCtrl", self.eventModel)
            end
        end)
    end
end

return QuestionsDialogCtrl