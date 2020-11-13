local ActivityModel = require("ui.models.activity.ActivityModel")
local LotteryMatchStatus = require("ui.models.activity.LotteryMatchStatus")

local LotteryModel = class(ActivityModel)

function LotteryModel:InitWithProtocol()
    table.sort(
        self.singleData.list,
        function(a, b)
            if a.matchStatus ~= b.matchStatus then
                if a.matchStatus == LotteryMatchStatus.BeforeMatch then
                    return true
                elseif a.matchStatus == LotteryMatchStatus.Finished then
                    return false
                else
                    -- a is InMatch
                    -- return true if b is finished
                    return b.matchStatus == LotteryMatchStatus.Finished
                end
            else
                return a.beginTime > b.beginTime
            end
        end
    )

    for key, item in pairs(self.singleData.list) do
        item.serverTime = self.singleData.serverTime
    end
end

function LotteryModel:UpdateModel(matchId, item)
    item.serverTime = self.singleData.serverTime

    for i, value in ipairs(self.singleData.list) do
        if value.matchId == matchId then
            self.singleData.list[i] = item
            EventSystem.SendEvent("LotteryModel:UpdateModel", i, item)
            break
        end
    end
end

function LotteryModel:RefreshData(data)
    LotteryModel.super.RefreshData(self, data)
    EventSystem.SendEvent("LotteryModel:RefreshData", data)
end

function LotteryModel:UpdateHistory(list, statistic)
    for key, item in pairs(list) do
        for i, value in ipairs(self.history.list) do
            if value.matchId == item.matchId and value.stakeResult == item.stakeResult then
                self.history.list[i] = item
                EventSystem.SendEvent("LotteryModel:UpdateHistory", i, item)
                break
            end
        end
    end

    self.history.statistic = statistic

    EventSystem.SendEvent("LotteryModel:UpdateHistoryStatistic", {statistic = statistic})
end

-- static method
function LotteryModel.GetTeamBadge(matchId, homeTeam, guestTeam)
    -- check if cached badge for teams
    -- if not, choose random one, make sure home ~= guest

    local badges = {}

    for i = 1, 17 do
        table.insert(badges, i)
    end

    local homeBadge = LotteryModel.GetCachedTeamBadge(matchId, homeTeam)
    if not homeBadge then
        homeBadge = math.floor(math.randomInRange(1, #badges))
        LotteryModel.SetCachedTeamBadge(matchId, homeTeam, homeBadge)
    end

    table.remove(badges, homeBadge)

    local guestBadge = LotteryModel.GetCachedTeamBadge(matchId, guestTeam)
    if not guestBadge then
        guestBadge = badges[math.floor(math.randomInRange(1, #badges))]
        LotteryModel.SetCachedTeamBadge(matchId, guestTeam, guestBadge)
    end

    return homeBadge, guestBadge
end

function LotteryModel.GetCachedTeamBadge(matchId, team)
    if not LotteryModel.cachedTeamBadges then
        LotteryModel.cachedTeamBadges = {}
    end
    if not LotteryModel.cachedTeamBadges[matchId] then
        LotteryModel.cachedTeamBadges[matchId] = {}
    end
    return LotteryModel.cachedTeamBadges[matchId][team]
end

function LotteryModel.SetCachedTeamBadge(matchId, team, badge)
    LotteryModel.cachedTeamBadges[matchId][team] = badge
end

function LotteryModel.GetBadgeIcon(badgeIndex)
    local path = string.format("Assets/CapstonesRes/Game/UI/Scene/Activties/Image/Lottery/badge%d.png", badgeIndex)
    local res = res.LoadRes(path)
    return res
end

return LotteryModel
