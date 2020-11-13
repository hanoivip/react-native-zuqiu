local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")

local CongratulationsMultiPageCtrl = class()

function CongratulationsMultiPageCtrl:ctor(rewardData, isGuideComment, isVisitInfo)
    self.rewardData = rewardData
    self.isGuideComment = isGuideComment
    self.isVisitInfo = isVisitInfo
    self.playerInfoModel = PlayerInfoModel.new()
    self:Init()
end

function CongratulationsMultiPageCtrl:Init()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Congratulations/CongratulationsMulti.prefab", "camera", false, true)
    local script = dialogcomp.contentcomp
    script:InitView(self.rewardData, self.playerInfoModel, self.isGuideComment, self.isVisitInfo)
end

return CongratulationsMultiPageCtrl