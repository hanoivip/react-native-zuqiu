local Model = require("ui.models.Model")
local PeakReward = require("data.PeakReward")
local PeakRewardNum = require("data.PeakRewardNum")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local PeakMainModel = class(Model)

function PeakMainModel:ctor()
    PeakMainModel.super.ctor(self)
end

function PeakMainModel:InitWithProtocol(data)
    assert(data)
    self.data = data
    self.staticData = {}
    self.staticData.teamOrder = {}
    self:InitTeamOrder(self.data.teamOrder)
    cache.setPeakTeamData(data.team.teamInfo)
end

function PeakMainModel:InitTeamOrder(tOrder)
    -- 转换成key为出场顺序，value为阵容编号
    self.staticData.teamOrder[tostring(tOrder.peak1)] = "peak1"
    self.staticData.teamOrder[tostring(tOrder.peak2)] = "peak2"
    self.staticData.teamOrder[tostring(tOrder.peak3)] = "peak3"
end

function PeakMainModel:GetSelfRank()
    return self.data.rank
end

function PeakMainModel:GetSelfScore()
    return tostring(self.data.peakDailyCount or 0)
end

function PeakMainModel:GetRewardPoint()
    return self.data.peakRewardPoint
end

function PeakMainModel:GetNextScoreStage()
    return self.data.nextScoreStageDistance
end

function PeakMainModel:GetTeamOrder()
    return self.staticData.teamOrder
end

function PeakMainModel:GetTeamShow()
    return clone(self.data.team.teamShow)
end

function PeakMainModel:SetTeamShow(tShow)
    self.data.team.teamShow = tShow
end

function PeakMainModel:GetTeamDataByLocIndex(index)
    return self.data.team.teamInfo[index]
end

function PeakMainModel:SwapLocTeamOrder(sourceMess, targetMess)
    self.staticData.teamOrder[sourceMess], self.staticData.teamOrder[targetMess] = self.staticData.teamOrder[targetMess], self.staticData.teamOrder[sourceMess]
end

-- key为位置 value为阵容id
function PeakMainModel:SetTeamOrder(orderData)
    assert(orderData)
    self.staticData.teamOrder = orderData
    EventSystem.SendEvent("Refresh_Formation_Item", orderData)
end

function PeakMainModel:GetTeamOrderService()
    local tOrder = {}
    for k, v in pairs(self.staticData.teamOrder) do
        tOrder[v] = k
    end
    return tOrder
end

-- 是否处于交换顺序的状态（锁定阵容不能）
function PeakMainModel:GetIsChangeOrderStatus()
    return self.data.changeOrderStatus
end

function PeakMainModel:SetChangeOrderStatus(bStatus)
    self.data.changeOrderStatus = bStatus
end

function PeakMainModel:GetIsLockStatus()
    return self.data.lockStatus
end

function PeakMainModel:SetLockStatus(status)
    self.data.lockStatus = status
end

function PeakMainModel:GetMaxChallengeTimes()
    return self.data.maxChallengeTimes
end

function PeakMainModel:GetRemainChallengeTimes()
    return self.data.peakChallengeTimes
end

function PeakMainModel:GetCdRemainTime()
    return self.data.cdRemainTime
end
-- 可以花钻石重置cd时间
function PeakMainModel:SetCdRemainTime(cdTime)
    self.data.cdRemainTime = cdTime
    EventSystem.SendEvent("Refresh_Cd_Time", self.data.cdRemainTime)
end

function PeakMainModel:GetSendRewardTime()
    return self.data.sendRewardTime
end

function PeakMainModel:SetSendRewardTime(time)
    self.data.sendRewardTime = time
    EventSystem.SendEvent("Refresh_Reward_Time", time)
end

function PeakMainModel:GetResetCdTimeConsume()
    return self.data.clearChallengeCDCost or 0
end

function PeakMainModel:SetResetCdTimeConsume(cost)
    self.data.clearChallengeCDCost = tonumber(cost)
end

function PeakMainModel:GetBuyChallengeTimeConsume()
    return self.data.buyChallengeCountCost or 0
end

function PeakMainModel:GetEndTime()
    return self.data.endTime - self.data.serverTime
end

function PeakMainModel:GetSeasonTag()
    return self.data.seasonTag
end

function PeakMainModel:IsTeamNull()
    return not (self.data.team.teamFlag["1"] or self.data.team.teamFlag["2"] or self.data.team.teamFlag["3"])
end

function PeakMainModel:GetDefualtTeam()
    local peakName = self.staticData.teamOrder["1"]
    local teamIndex = string.sub(peakName, -1)
    local playerTeamsModel = require("ui.models.PlayerTeamsModel").new()
    playerTeamsModel:SetTeamType(FormationConstants.TeamType.PEAK)
    local teamData = playerTeamsModel:GetNowTeamData() or {}
    if teamData.rep and next(teamData.rep) then
        for k,v in pairs(teamData.rep) do 
            if tonumber(v) == 0 then
                teamData.rep[k] = nil
            end
        end
    end
    teamData.ptid = tonumber(teamIndex) - 1
    teamData.tid = tonumber(teamIndex) - 1
    self.data.team.teamInfo["1"] = teamData
    self.data.team.teamFlag["1"] = true
    cache.setPeakTeamData(self.data.team.teamInfo)
    return teamData or {}
end

function PeakMainModel:GetPeakCount()
    for k,v in pairs(PeakRewardNum) do
        if self.data.peakDailyCount >= v.peakCountReward then
            return v.exchangeTimes
        end
    end
    return 0
end

function PeakMainModel:GetPeakPoint()
    for k,v in pairs(PeakRewardNum) do
        if self.data.peakDailyCount >= v.peakCountReward then
            return v.peakPoint
        end
    end
    return 0
end

function PeakMainModel:GetPrePeakDailyCount()
    return self.data.prePeakDailyCount
end

function PeakMainModel:IsHideScore()
    return self.data.hideScore
end

function PeakMainModel:GetIsMaxScore()
    return self.data.peakDailyCount >= PeakRewardNum[1].peakCountReward
end

return PeakMainModel