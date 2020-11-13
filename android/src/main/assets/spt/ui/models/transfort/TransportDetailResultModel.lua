local Model = require("ui.models.Model")
local TeamSponsor = require("data.TeamSponsor")
local SponsorUpgrade = require("data.SponsorUpgrade")

local TransportDetailResultModel = class(Model)

function TransportDetailResultModel:InitWithProtocol(data)
    assert(data)
    self.data = data
end

function TransportDetailResultModel:GetName()
    return self.data.express.name
end

function TransportDetailResultModel:GetServer()
    return self.data.express.serverName
end

function TransportDetailResultModel:GetLogo()
    return self.data.express.logo
end

function TransportDetailResultModel:GetLvl()
    return self.data.express.lvl
end

function TransportDetailResultModel:GetPower()
    return self.data.express.power
end

function TransportDetailResultModel:GetVipLvl()
    return self.data.express.vip
end

function TransportDetailResultModel:GetSponsorId()
    return self.data.express.sponsorId
end

function TransportDetailResultModel:GetBaseReward()
    return self.data.express.sponsorReward.baseReward
end

function TransportDetailResultModel:GetSpecialReward()
    return self.data.express.sponsorReward.specialReward
end

function TransportDetailResultModel:GetPid()
    return self.data.express.pid
end

function TransportDetailResultModel:GetSid()
    return self.data.express.sid
end

function TransportDetailResultModel:GetMaxBaseRewardRobberyTimes()
    return self.data.express.maxBaseRewardRobberyTimes
end

function TransportDetailResultModel:GetMaxSpecialRewardRobberyTimes()
    return self.data.express.maxSpecialRewardRobberyTimes
end

function TransportDetailResultModel:GetRobberyRewardTimes()
    return (self.data.express.robberyRewardTimes >= 0 and self.data.express.robberyRewardTimes) or 0
end

function TransportDetailResultModel:GetRobberySpecialRewardTimes()
    return (self.data.express.robberySpecialRewardTimes >= 0 and self.data.express.robberySpecialRewardTimes) or 0
end

function TransportDetailResultModel:GetRobberyHistoryData()
    local matchData = {}
    for k, v in pairs(self.data.express.matchData or {}) do
        table.insert(matchData, v)
    end
    return matchData
end

function TransportDetailResultModel:GetTipBaseRewardPercent()
    return self.data.robberyReward.baseRewardRobberyPercent
end

function TransportDetailResultModel:GetTipSpecialRewardCount()
    return self.data.robberyReward.specialRewardRobberyCount
end

function TransportDetailResultModel:GetTipSpecialProbability()
    return SponsorUpgrade[tostring(self.data.express.sponsorId)].specialRewardStealprobability
end

function TransportDetailResultModel:GetIsHaveGuard()
    return self.data.express.guardPlayer
end

function TransportDetailResultModel:GetRobberyBaseCount()
    return self.data.express.robberyBaseRewardCount
end

function TransportDetailResultModel:GetRobberySpecialCount()
    return self.data.express.robberySpecialRewardCount
end

function TransportDetailResultModel:GetGuardLogo()
    return self.data.express.guardPlayer and self.data.express.guardPlayer.logo
end

function TransportDetailResultModel:GetGuardName()
    return self.data.express.guardPlayer and self.data.express.guardPlayer.name
end

function TransportDetailResultModel:GetGuardPower()
    return self.data.express.guardPlayer and self.data.express.guardPlayer.power
end

function TransportDetailResultModel:GetGuardPid()
    return self.data.express.guardPlayer and self.data.express.guardPlayer.pid
end

function TransportDetailResultModel:GetGuardSid()
    return self.data.express.guardPlayer and self.data.express.guardPlayer.sid
end

return TransportDetailResultModel