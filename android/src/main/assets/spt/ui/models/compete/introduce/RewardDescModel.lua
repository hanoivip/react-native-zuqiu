local Model = require("ui.models.Model")
local DescData = require("data.WorldTournamentExplain")
local IntroduceConstants = require("ui.models.compete.introduce.IntroduceConstants")
local RewardDescModel = class(Model)

function RewardDescModel:GetProcessDesc()
    return DescData[IntroduceConstants.PROCESS_DESC_INDEX]["desc"]
end

function RewardDescModel:GetCrossDesc()
    return DescData[IntroduceConstants.CROSS_DESC_INDEX]["desc"]
end

function RewardDescModel:GetPlayingDesc()
    return DescData[IntroduceConstants.PLAYING_DESC_INDEX]["desc"]
end

function RewardDescModel:GetLeagueUpgradeDesc()
    return DescData[IntroduceConstants.UPGRADE_DESC_INDEX]["desc"]
end

function RewardDescModel:GetEarCupNumDesc()
    return DescData[IntroduceConstants.EARCUPNUM_DESC_INDEX]["desc"]
end

function RewardDescModel:GetCrossScoreDesc()
    return DescData[IntroduceConstants.CROSSSCORE_DESC_INDEX]["desc"]
end

function RewardDescModel:GetRewardBoxDesc()
    return DescData[IntroduceConstants.REWARDBOX_DESC_INDEX]["desc"]
end

function RewardDescModel:GetRewardTypeDesc()
    return DescData[IntroduceConstants.REWARD_TYPE_INDEX]["desc"]
end

return RewardDescModel