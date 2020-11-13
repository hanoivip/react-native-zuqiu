local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GuildChallengeRewardsModel = require("ui.models.guild.GuildChallengeRewardsModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local GuildChallengeRewardsCtrl = class()

function GuildChallengeRewardsCtrl:ctor()
    self.guildChallengeRewardsModel = GuildChallengeRewardsModel.new()
    self:Init()
end

function GuildChallengeRewardsCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    local matchResultData = self.guildChallengeRewardsModel:GetMatchResultData()
    if matchResultData == nil then
        return
    end

    -- 比赛的奖励是否已结算过
    if matchResultData.hasSettle == false and matchResultData.matchType == MatchConstants.MatchType.GUILDCHALLENGE then
        local isPass = self.guildChallengeRewardsModel:GetIsPass()
        self:SettleReward()
        matchResultData.hasSettle = true
        if isPass then
            self:ShowRewardView()
            self:SetEnterViewEventSystem()
        end
    end
end

--- 显示关卡结算面板
function GuildChallengeRewardsCtrl:ShowRewardView()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildChallengeRewards.prefab", "camera", true, true)
    local script = dialogcomp.contentcomp
    script:InitView(self.guildChallengeRewardsModel:GetSettlementData())
end

function GuildChallengeRewardsCtrl:SetEnterViewEventSystem()
    EventSystem.SendEvent("ChallengeEnterView_Refresh", self.guildChallengeRewardsModel:GetStarNum())
end

-- 结算奖励
function GuildChallengeRewardsCtrl:SettleReward()
    local isPass = self.guildChallengeRewardsModel:GetIsPass()
    self.playerInfoModel:SetStrength(self.guildChallengeRewardsModel:GetSp())
    if isPass == true then
        local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
        rewardUpdateCacheModel:UpdateCache(self.guildChallengeRewardsModel:GetSettlementDataContents())
    end
end

return GuildChallengeRewardsCtrl