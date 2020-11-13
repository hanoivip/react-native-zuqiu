local GuildChallengeSweepRewardsModel = require("ui.models.guild.GuildChallengeSweepRewardsModel")
local CustomEvent = require("ui.common.CustomEvent")

local GuildChallengeSweepRewardsCtrl = class()

function GuildChallengeSweepRewardsCtrl:ctor(qid, diff)
    self:Init(qid, diff)
end

function GuildChallengeSweepRewardsCtrl:Init(qid, diff)
    clr.coroutine(function()
        local response = req.challengeSweep(qid, diff)
        if api.success(response) then
            local data = response.val
            self:InstantiateSweepOnce()
            self:BuildSweepOnceData(data)
            self:InitView()
            EventSystem.SendEvent("ChallengeEnterView_SweepReduceCount")
        end
    end)
end

function GuildChallengeSweepRewardsCtrl:InstantiateSweepOnce()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildChallengeSweepRewards.prefab", "camera", true, true)
    self.sweepScript = dialogcomp.contentcomp
end

function GuildChallengeSweepRewardsCtrl:InitView()
    self.sweepScript:InitView(self.guildChallengeSweepRewardsModel:GetRewardData())
end

function GuildChallengeSweepRewardsCtrl:BuildSweepOnceData(data)
    self.guildChallengeSweepRewardsModel = GuildChallengeSweepRewardsModel.new(data)
end

return GuildChallengeSweepRewardsCtrl