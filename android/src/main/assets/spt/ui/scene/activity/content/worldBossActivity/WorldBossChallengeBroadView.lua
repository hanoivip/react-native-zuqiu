local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local WorldBossChallengeBroadView = class(unity.base)

function WorldBossChallengeBroadView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.rankTitleName = self.___ex.rankTitleName
    self.oppendName = self.___ex.oppendName
    self.oppendInfo = self.___ex.oppendInfo
    self.challengeScore = self.___ex.challengeScore
    self.challengePower = self.___ex.challengePower
    self.challengeRewardArea = self.___ex.challengeRewardArea
    self.challengeRewardInfo1 = self.___ex.challengeRewardInfo1
    self.challengeRewardInfo2 = self.___ex.challengeRewardInfo2
    self.challengeReward = self.___ex.challengeReward
    self.rediusCount = self.___ex.rediusCount
    self.handChallenge = self.___ex.handChallenge
    self.sweepChallenge = self.___ex.sweepChallenge
end

function WorldBossChallengeBroadView:start()
    self.handChallenge:regOnButtonClick(function ()
        self:OnChallenge(false)
    end)
    self.sweepChallenge:regOnButtonClick(function ()
        self:OnChallenge(true)
    end)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, nil)
end

function WorldBossChallengeBroadView:InitView(worldBossChallengeModel)
    self:SetSweepState(worldBossChallengeModel:GetSweepState())
    self.rankTitleName.text = worldBossChallengeModel:GetTitle()
    self.oppendName.text = worldBossChallengeModel:GetTitle() .. ":"
    self.oppendInfo.text = worldBossChallengeModel:GetOppendInfo()
    self.challengeScore.text = worldBossChallengeModel:GetScoreInfo()
    self.challengePower.text = worldBossChallengeModel:GetPowerInfo()
    self.rediusCount.text = lang.trans("challenge_leftCount", worldBossChallengeModel:GetRediusCount()) 
    self:InitDwonReward(worldBossChallengeModel:GetDiamondCounts())
    self:InitUpReward(worldBossChallengeModel:GetRewardContents())
end

function WorldBossChallengeBroadView:OnChallenge(isSweep)
    if self.onChallenge then
        self.onChallenge(isSweep)
    end
end

function WorldBossChallengeBroadView:ResetCount(data)
    self.rediusCount.text = lang.trans("challenge_leftCount", data) 
end

function WorldBossChallengeBroadView:SetSweepState(state)
    self.sweepChallenge.gameObject:SetActive(state)
end

function WorldBossChallengeBroadView:InitUpReward(contentsList)
    res.ClearChildren(self.challengeRewardArea.transform)
    for k,v in pairs(contentsList) do
        local rewardParams = {
            parentObj = self.challengeRewardArea,
            rewardData = v.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = false,
            isShowCardReward = false,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function WorldBossChallengeBroadView:InitDwonReward(diamondList)
    local diamondRewarContents = {}
    for k,v in pairs(self.challengeReward) do
        diamondRewarContents.d = diamondList[tonumber(k)]
        res.ClearChildren(v.transform)
        local rewardParams = {
            parentObj = v,
            rewardData = diamondRewarContents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = false,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function WorldBossChallengeBroadView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function WorldBossChallengeBroadView:CloseImmediate()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return WorldBossChallengeBroadView
