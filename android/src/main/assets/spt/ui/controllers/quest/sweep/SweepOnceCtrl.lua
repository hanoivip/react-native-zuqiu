local SweepListModel = require("ui.models.quest.sweep.SweepListModel")
local CustomEvent = require("ui.common.CustomEvent")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")

local SweepOnceCtrl = class()

function SweepOnceCtrl:ctor(stageInfoModel)
    self:Init(stageInfoModel)
end

function SweepOnceCtrl:Init(stageInfoModel)
    clr.coroutine(function()
        local qid = stageInfoModel:GetStageId()
        local response = req.questSweep(qid)
        if api.success(response) then
            local data = response.val -- 执行顺序影响遮挡顺序
            self:InstantiateSweepOnce()
            self:BuildSweepOnceData(data)
            self:UpdateStageInfo(stageInfoModel, qid, data.questInfo)

            self:InitView()
            NewYearCongratulationsPageCtrl.new(data, NewYearOutPutPosType.QUEST)
        end
    end)
end

function SweepOnceCtrl:InstantiateSweepOnce()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Quest/SweepOnceRewards.prefab", "camera", true, true)
    self.sweepScript = dialogcomp.contentcomp
end

function SweepOnceCtrl:InitView()
    self.sweepScript:InitView(self.sweepListModel)
end

function SweepOnceCtrl:BuildSweepOnceData(data)
    self.sweepListModel = SweepListModel.new(data)
end

function SweepOnceCtrl:UpdateStageInfo(stageInfoModel, qid, questInfo)
    EventSystem.SendEvent("QuestPage_UpdateInfo", questInfo)
end

return SweepOnceCtrl