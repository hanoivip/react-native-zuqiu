-- 比赛录像回放的结果发送给服务器进行比对 存日志
local ReplayCheckHelper = {}

--replayCheck={
--    "matchType":"peak",
--    "id": "239q093ugfjuvlawejdfpowri",
--    "result": {
--        "old": {
--        "version": "1",
--        "score": "2",
--        "opponentScore": "1"
--    },
--        "new": {
--            "version": "1",
--            "score": "2",
--            "opponentScore": "1"
--        }
--    }
--}

function ReplayCheckHelper.AddOldReplayScoreData(replayData, vid)
    local coreVersion = require("emulator.version")
    local version = coreVersion.version
    local replayCheck = {}
    replayCheck.matchType = replayData.baseInfo.matchType
    replayCheck.id = vid
    replayCheck.result = {}
    replayCheck.result.old = {}
    replayCheck.result.new = {}
    replayCheck.result.old.version = replayData.baseInfo.version
    replayCheck.result.old.score = replayData.result.player.totalScore or replayData.result.player.score
    replayCheck.result.old.opponentScore = replayData.result.opponent.totalScore or replayData.result.opponent.score
    replayCheck.result.new.version = version
    replayData.replayCheck = replayCheck
    return replayData
end

function ReplayCheckHelper.SendReplayCheck(replayData, playerScore, opponentScore, isSkipped, isGiveUp)
    local replayCheck = replayData.replayCheck
    replayCheck.isSkipped = isSkipped
    replayCheck.isGiveUp = isGiveUp
    replayCheck.result.new.score = playerScore
    replayCheck.result.new.opponentScore = opponentScore
    clr.coroutine(function ()
        local response = req.matchRecordResult(replayCheck)
        if api.success(response) then
            local data = response.val
            dump(data,"Send Replay Check Success:")
        end
    end)
end

function ReplayCheckHelper.StartReplay(replayData, vid)
    local MatchLoader = require("coregame.MatchLoader")
    local data = ReplayCheckHelper.AddOldReplayScoreData(replayData, vid)
    MatchLoader.startMatch(data)
end

return ReplayCheckHelper
