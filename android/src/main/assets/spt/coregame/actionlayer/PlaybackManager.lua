local ActionLayerUtils = require("coregame.actionlayer.ActionLayerUtils")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local EnumType = require("coregame.EnumType")
local BallPassType = EnumType.BallPassType
local PlaybackClipType = EnumType.PlaybackClipType
local MatchEventType = EnumType.MatchEventType

local PlaybackManager = class()

function PlaybackManager:Start()
    ___playbackManager = self
    self.startTime = nil
    self.startEvent = nil
    self.endEvent = nil
    self.lastPass = nil
    self.clipType = nil
    self.loopCount = nil
    self.playbackTimes = nil
    self.inShooting = nil
    self.shooter = nil
    self.inPlayback = nil
    self.inSlowMotion = nil
    self.shootStartTime = nil
    self.waitFotMatchBreak = nil
    self.isPlaybackMatchHighlights = nil
    self.isSavedAsHighlights = nil
    self.matchHighlightsInfo = {}
    self.goalPlayers = {}
    self.matchHighlightsIndexArray = {}
    self.matchHighlightsIndex = nil
    self.isFromLeftToRight = nil
    self.matchInfoModel = MatchInfoModel.GetInstance()
end

function PlaybackManager:Destroy()
    self.startTime = nil
    self.startEvent = nil
    self.endEvent = nil
    self.lastPass = nil
    self.clipType = nil
    self.loopCount = nil
    self.playbackTimes = nil
    self.inShooting = nil
    self.shooter = nil
    self.inPlayback = nil
    self.inSlowMotion = nil
    self.shootStartTime = nil
    self.isPlaybackMatchHighlights = nil
    self.isSavedAsHighlights = nil
    self.matchHighlightsInfo = nil
    self.goalPlayers = nil
    self.matchHighlightsIndexArray = nil
    self.matchHighlightsIndex = nil
    self.isFromLeftToRight = nil
    self.matchInfoModel = nil
end

function PlaybackManager:StartRecording(recordStartTime, bufferLength, startMatchEvent)
    self.startEvent = startMatchEvent
    PlaybackCenterWrap.StartRecording(recordStartTime, bufferLength)
end

function PlaybackManager:StopRecording(endMatchEvent, inShooting, shooter)
    self.endEvent = endMatchEvent.matchEvent
    self.inShooting = inShooting
    self.shooter = shooter
    --暂时保存双方的进球集锦
    self.isSavedAsHighlights = not self.matchInfoModel:IsDemoMatch()
        and self.endEvent == MatchEventType.TimedKickOff
        and self.startEvent ~= MatchEventType.PenaltyShootOutKick
    PlaybackCenterWrap.StopRecording(self.startEvent, self.isSavedAsHighlights)
    if self.isSavedAsHighlights then
        local athleteId = GameHubWrap.GetAthleteId(shooter)
        if self.goalPlayers[athleteId] == nil then
            self.goalPlayers[athleteId] = 1
        else
            self.goalPlayers[athleteId] = self.goalPlayers[athleteId] + 1
        end
        table.insert(self.matchHighlightsInfo, {
            goalPlayer = athleteId,
            goalCount = self.goalPlayers[athleteId],
            goalTime = endMatchEvent.time,
            isFromLeftToRight = GameHubWrap.IsFromLeftToRight() })
    end
end

function PlaybackManager:StartPlayback()
    PlaybackCenterWrap.StartPlayback()
    ___matchUI.fightMenuManager:StartPlayback()
end

function PlaybackManager:StopPlayback()
    if self.inPlayback == true then
        local delay = self.matchInfoModel:IsDemoMatch() and ___demoManager:GetStopPlaybackDelay() or self:GetStopPlaybackDelay()
        GameHubWrap.StopPlayback(delay, self.playbackTimes >= self.loopCount)
        self.inPlayback = self.playbackTimes < self.loopCount
    end
end

function PlaybackManager:SkipPlayback()
    if self.inPlayback == true then
        local delay = self.matchInfoModel:IsDemoMatch() and 0.1 or 0.5
        GameHubWrap.StopPlayback(delay, true)
        self.inPlayback = false
    end
end

function PlaybackManager:GetStopPlaybackDelay()
    return self.inSlowMotion == true and 0.2 or 0.5
end

function PlaybackManager:InitPlaybackClip(startTime, startMatchEvent, lastPass, shootStartTime)
    self.startTime = startTime
    self.startEvent = startMatchEvent
    self.lastPass = lastPass
    self.shootStartTime = shootStartTime

    self.clipType = PlaybackClipType.Goal_Ordinary
    if endMatchEvent == MatchEventType.IndirectFreeKick then
        self.clipType = PlaybackClipType.Offside
    else
        if startMatchEvent == MatchEventType.CenterDirectFreeKick then
            self.clipType = PlaybackClipType.Goal_DirectFreeKick
        elseif startMatchEvent == MatchEventType.PenaltyKick
            or startMatchEvent == MatchEventType.PenaltyShootOutKick then
            self.clipType = PlaybackClipType.Goal_Penalty
        elseif startMatchEvent == MatchEventType.CornerKick then
            self.clipType = PlaybackClipType.Goal_CornerKick
        else
            local passType = lastPass.passType
            if passType == BallPassType.PassGroundStraight then
                --if distance in Z direction of the last pass(ground) is larger than 20m
                --then deal with it as through ball
                if math.abs(lastPass.startPosition.z - lastPass.endPosition.z) >= 20 then
                    self.clipType = PlaybackClipType.Goal_ThroughPassAssist
                end
            elseif passType == BallPassType.HeaderPass then
                self.clipType = PlaybackClipType.Goal_HeaderPassAssist
            elseif passType == BallPassType.PassAirStraight or
                passType == BallPassType.PassRainbow or
                passType == BallPassType.PassRainbowInCurve or
                passType == BallPassType.PassRainbowOutCurve then
                --if distance of the last pass(high) is larger than 30m
                --then take it as over head pass
                if ActionLayerUtils.Vector3SqrDistanceOnXZ(lastPass.startPosition, lastPass.endPosition) >= 900 then
                    self.clipType = PlaybackClipType.Goal_OverheadPassAssist
                end
            end
        end
    end

    if self.isPlaybackMatchHighlights
        or self.inShooting == false
        or self.shooter >= 11
        or self.clipType == PlaybackClipType.Goal_Penalty
        or self.clipType == PlaybackClipType.Offside then
        self.loopCount = 1
    else
        self.loopCount = 3
    end
    ___cameraCtrlCore:clearUsedPlayBackCameraParameterIndices()

    self.inPlayback = true
    self.playbackTimes = 0
    self.inSlowMotion = false
    self.waitFotMatchBreak = false
    self:StartPlaybackClip()
end

function PlaybackManager:OnLastPassInPlayback()
    if self.playbackTimes == 1 then
        --TODO on last pass in play back!!
    end
end

function PlaybackManager:StartPlaybackClip()
    self.playbackTimes = self.playbackTimes + 1
    if self.playbackTimes == 3 then
        self:StartSlowMotion()
        if self:ShouldPlaybackShortVersion() then
            PlaybackCenterWrap.StartPlaybackClip(self.shootStartTime - 2)
            return
        end
    end
    if self.isPlaybackMatchHighlights then
        --ui: shooter & goal time & goal count
        local clipData = self.matchHighlightsInfo[self.matchHighlightsIndexArray[self.matchHighlightsIndex]]
        self.isFromLeftToRight = clipData.isFromLeftToRight
    end
    ___upperBodyUtil:OnPlaybackStarts()
    PlaybackCenterWrap.StartPlaybackClip(self.startTime)
    if not self.isPlaybackMatchHighlights then
        if self.matchInfoModel:IsDemoMatch() then
            ___demoManager:OnPlaybackStarts()
        elseif self.playbackTimes == 1 then
            if self.clipType == PlaybackClipType.Goal_Penalty
                or self.clipType == PlaybackClipType.Goal_CornerKick
                or self.clipType == PlaybackClipType.Goal_DirectFreeKick then
                TimeWrap.SetTimeScale(0)
                self.waitFotMatchBreak = true
            end
        end
    end
end

function PlaybackManager:OnPlaybackEnds()
    if not self.isPlaybackMatchHighlights then
        ___matchUI.fightMenuManager:StopPlayback()
        self:EndSlowMotion()
    end
    self.inPlayback = false
    self.waitFotMatchBreak = false
    ___upperBodyUtil:OnPlaybackEnds()
    if self.matchInfoModel:IsDemoMatch() then
        ___demoManager:OnPlaybackEnds()
    end
    --如果处于集锦回放中，则继续回放下一个进球片段
    if self.isPlaybackMatchHighlights then
        self.matchHighlightsIndex = self.matchHighlightsIndex + 1
        if self.matchHighlightsIndex <= #self.matchHighlightsIndexArray then
            PlaybackCenterWrap.StartPlaybackMatchHighlights(self.matchHighlightsIndexArray[self.matchHighlightsIndex] - 1)
        else
            self:OnMatchHighlightsEnds()
        end
    end
end

function PlaybackManager:OnPlaybackClipEnds()
    ___matchUI:disableGoalNet()
    self:EndSlowMotion()
    self:StartPlaybackClip()
end

--获取进球集锦（分片段）信息
function PlaybackManager:GetMatchHighlightsData()
    return self.matchHighlightsInfo
end

--播放进球集锦，参数为集锦列表的下标数组
function PlaybackManager:StartPlaybackMatchHighlights(indexArray, onMatchHighlightsEndFunc)
    if indexArray and #indexArray > 0 then
        self.matchHighlightsIndexArray = indexArray
        self.matchHighlightsIndex = 1
        self.onMatchHighlightsEndFunc = onMatchHighlightsEndFunc

        TimeWrap.SetTimeScale(1)
        self.isPlaybackMatchHighlights = true

        ___deadBallTimeManager:StartPlaybackMatchHighlights()
        ___matchUI:startPlaybackMatchHighlights()

        PlaybackCenterWrap.StartPlaybackMatchHighlights(self.matchHighlightsIndexArray[self.matchHighlightsIndex] - 1)
    end
end

function PlaybackManager:OnMatchHighlightsEnds()
    self.isPlaybackMatchHighlights = false
    ___cameraCtrlCore:setLookAtSpectatorCamera()
    if self.onMatchHighlightsEndFunc and type(self.onMatchHighlightsEndFunc) == 'function' then
        self.onMatchHighlightsEndFunc()
    end
end

function PlaybackManager:StartSlowMotion()
    self.inSlowMotion = true
    TimeWrap.SetTimeScale(0.5)
end

function PlaybackManager:EndSlowMotion()
    if self.inSlowMotion == true then
        self.inSlowMotion = false
        TimeWrap.SetTimeScale(1)
    end
end

function PlaybackManager:ShouldPlaybackShortVersion()
    return self.shootStartTime - 2 > self.startTime
        and self.clipType ~= PlaybackClipType.Goal_DirectFreeKick
        and self.clipType ~= PlaybackClipType.Goal_CornerKick
        and self.clipType ~= PlaybackClipType.Goal_Penalty
end

function PlaybackManager:OnMatchBreakAnimEnd()
    if self.waitFotMatchBreak == true then
        TimeWrap.SetTimeScale(1)
        self.waitFotMatchBreak = false
    end
end

function PlaybackManager:GetIsFromLeftToRightInMatchHighlights()
    return self.isFromLeftToRight
end

return PlaybackManager