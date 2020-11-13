local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local CongratulationsMultiPageCtrl = require("ui.controllers.congratulations.CongratulationsMultiPageCtrl")
local CongratulationsPageCtrl = class()

function CongratulationsPageCtrl:ctor(rewardData, isGuideComment, isVisitInfo)
    self.rewardData = rewardData
    self.isGuideComment = isGuideComment
    self.isVisitInfo = isVisitInfo
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:LockLevelUp()
    self.playerInfoModel:LockVIPLevelUp()
    self:Init()
    local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
    rewardUpdateCacheModel:UpdateCache(rewardData)
end
function CongratulationsPageCtrl:Init()
    local isUseMultiPage = self:IsUseMultiPage()
    local isUseDreamCardPage = self:IsUseDreamCardPage()
    if isUseDreamCardPage then
        local path  = "ui.controllers.dreamLeague.congratulationsDreamCardPage.CongratulationsDreamCardPageCtrl"
        res.PushDialog(path, self.rewardData)
        return
    end
    if isUseMultiPage then
        CongratulationsMultiPageCtrl.new(self.rewardData, self.isGuideComment, self.isVisitInfo)
        return
    end
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Congratulations/Congratulations.prefab", "camera", false, true)
    local script = dialogcomp.contentcomp
    script:InitView(self.rewardData, self.playerInfoModel, self.isGuideComment, self.isVisitInfo)
end

-- 判断奖励是否大于3个
function CongratulationsPageCtrl:IsUseMultiPage()
    local num = 0
    for k, v in pairs(self.rewardData) do
        num = num + (type(v) ~= "table" and 1 or table.nums(self.rewardData[k]))
    end

    -- 金币有两个字段控制
    if self.rewardData.m ~= nil and self.rewardData.mDetail ~= nil then
        self.count = self.count - table.nums(self.rewardData.mDetail)
    end

    -- exp奖励有可能是个table
    if self.rewardData.exp ~= nil and type(self.rewardData.exp) == "table" then
        num = num - table.nums(self.rewardData.exp)
        num = num + 1
    end

    return num > 3
end

function CongratulationsPageCtrl:IsUseDreamCardPage()
    if type(self.rewardData.dreamCard) == "table" and #self.rewardData.dreamCard > 0 then
        return  true
    end
    return false
end

return CongratulationsPageCtrl