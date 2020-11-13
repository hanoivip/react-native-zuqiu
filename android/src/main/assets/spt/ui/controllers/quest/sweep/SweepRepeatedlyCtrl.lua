local SweepListModel = require("ui.models.quest.sweep.SweepListModel")
local CustomEvent = require("ui.common.CustomEvent")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")

local SweepRepeatedlyCtrl = class()

function SweepRepeatedlyCtrl:ctor(stageInfoModel, sweepTime)
    self:Init(stageInfoModel, sweepTime)
end

function SweepRepeatedlyCtrl:Init(stageInfoModel, sweepTime)
    clr.coroutine(function()
        local qid = stageInfoModel:GetStageId()
        local response = req.questSweepTen(qid, sweepTime)
        if api.success(response) then -- 执行顺序影响遮挡顺序
            local data = response.val
            self:InstantiateSweepRepeatedly()
            self:BuildSweepListData(data)
            self:UpdateStageInfo(stageInfoModel, qid, data.questInfo)

            self:InitView()
            NewYearCongratulationsPageCtrl.new(data, NewYearOutPutPosType.TRANSPORT)
        end
    end)
end

function SweepRepeatedlyCtrl:InstantiateSweepRepeatedly()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Quest/SweepRepeatedlyRewards.prefab", "camera", true, true)
    self.sweepRepeatedlyScript = dialogcomp.contentcomp
end

function SweepRepeatedlyCtrl:InitView()
    self.sweepRepeatedlyScript:InitView(self.sweepListModel)
end

function SweepRepeatedlyCtrl:BuildSweepListData(data)
    self.sweepListModel = SweepListModel.new(data)
end

function SweepRepeatedlyCtrl:UpdateStageInfo(stageInfoModel, qid, questInfo)
    EventSystem.SendEvent("QuestPage_UpdateInfo", questInfo)
end

return SweepRepeatedlyCtrl