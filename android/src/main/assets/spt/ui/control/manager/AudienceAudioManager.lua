local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local ActionLayer = clr.ActionLayer
local ShootResult = ActionLayer.ShootResult

local AudioManager = require("unity.audio")
local AudienceAudioConstants = require("ui.scene.match.AudienceAudioConstants")
local CommentaryManager = require("ui.control.manager.CommentaryManager")
local MatchInfoModel = require("ui.models.MatchInfoModel")

local AudienceAudioManager = class(unity.base)

local VOLUME_CONFIG = {
    PLAYER_DEFAULT = 0.7,
    PLAYER2_DEFAULT = 0.46,
    PLAYER3_DEFAULT = 0.3,
    PLAYER6_DEFAULT = 0.4,
    PLAYER5_DEFAULT = 0.46,
    CHEER_PLAYER_DEFAULT = 0.8,
    VOLUME_RATE = 0.85,
}

function AudienceAudioManager:ctor()
    -- 观众背景音播放器1
    self.audienceBgAudioPlayer = nil
    -- 观众背景音播放器2
    self.audienceBgAudioPlayer2 = nil
    -- 观众背景音播放器3
    self.audienceBgAudioPlayer3 = nil
    -- 观众背景音播放器6
    self.audienceBgAudioPlayer6 = nil
    -- 观众背景音播放器5
    self.audienceBgAudioPlayer5 = nil
    -- 观众欢呼播放器1
    self.audienceCheerFirstAudioPlayer = nil
    -- 观众欢呼播放器2
    self.audienceCheerSecondAudioPlayer = nil
    -- 观众欢呼播放器1是否播放结束
    self.isCheerFirstAudioEnded = true
    -- 观众欢呼播放器2是否播放结束
    self.isCheerSecondAudioEnded = true
    -- 观众欢呼声1是否正在切换
    self.isCheerFirstAudioInSwitch = false
    -- 观众欢呼声2是否正在切换
    self.isCheerSecondAudioInSwitch = false
    -- 其他声音播放器
    self.otherAudioPlayer = nil
    -- 背景音音量
    self.bgmVolume = 0.4
    -- 背景音乐索引
    self.bgAudioIndex = nil
    -- 正在播放的观众欢呼声索引
    self.playingCheerAudioIndex = nil
    -- 正在播放的观众欢呼声列表
    self.playeringCheerAudioList = nil
    -- 我方比分
    self.playerScore = 0
    -- 对方比分
    self.opponentScore = 0
    -- 观众背景音播放器5最后播放的音频索引
    self.lastAudioIndexOnAudioPlayer5 = nil
    -- 观众背景音播放器5是否播放结束
    self.isAudio5Ended = true
    -- 在静音过程中
    self.inVolumeFade = false
    -- 是否为示例赛
    self.isDemoMatch = MatchInfoModel.GetInstance():IsDemoMatch()
end

function AudienceAudioManager:start()
    self.audienceBgAudioPlayer = AudioManager.GetPlayer("audienceBg")
    self.audienceBgAudioPlayer2 = AudioManager.GetPlayer("audienceBg2")
    self.audienceBgAudioPlayer3 = AudioManager.GetPlayer("audienceBg3")
    self.audienceBgAudioPlayer6 = AudioManager.GetPlayer("audienceBg6")
    self.audienceBgAudioPlayer5 = AudioManager.GetPlayer("audienceBg5")
    self.audienceCheerFirstAudioPlayer = AudioManager.GetPlayer("audienceCheerFirst")
    self.audienceCheerSecondAudioPlayer = AudioManager.GetPlayer("audienceCheerSecond")
    self.otherAudioPlayer = AudioManager.GetPlayer("other")
    self:PlayAudienceBgAudio(true)
    self:PlayAudienceBgAudio2()
    self:PlayAudienceBgAudio3()
    self:PlayOutscoreAudienceBgAudio()
    self:RegisterEvent()
    self:RegisterAudioListener()
end

--- 获取随机项
function AudienceAudioManager:RandomItem(audioTable)
    return audioTable[self:RandomNum(#audioTable)]
end

function AudienceAudioManager:RandomNum(num)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    return math.random(num)
end

function AudienceAudioManager:RegisterAudioListener()
    AudioManager.RegListener("audienceBg", function()
        self:PlayAudienceBgAudio(false)
    end, "audienceBg")

    AudioManager.RegListener("audienceBg5", function()
        self.isAudio5Ended = true
        DOTween.Kill("audienceBg5")
        local mySequence = DOTween.Sequence()
        TweenSettingsExtensions.SetId(mySequence, "audienceBg5")
        TweenSettingsExtensions.AppendInterval(mySequence, 5)
        TweenSettingsExtensions.AppendCallback(mySequence, function ()
            self:PlayOutscoreAudienceBgAudio()
        end)
    end, "audienceBg5")

    AudioManager.RegListener("audienceCheerFirst", function()
        self.isCheerFirstAudioEnded = true
        self:PlayNextAudienceCheerAudio()
    end, "audienceCheerFirst")

    AudioManager.RegListener("audienceCheerSecond", function()
        self.isCheerSecondAudioEnded = true
        self:PlayNextAudienceCheerAudio()
    end, "audienceCheerSecond")
end

function AudienceAudioManager:RemoveAudioListener()
    AudioManager.RegListener("audienceBg", nil, "audienceBg")
    AudioManager.RegListener("audienceBg5", nil, "audienceBg5")
    AudioManager.RegListener("audienceCheerFirst", nil, "audienceCheerFirst")
    AudioManager.RegListener("audienceCheerSecond", nil, "audienceCheerSecond")
end

function AudienceAudioManager:RegisterEvent()
    EventSystem.AddEvent("AudienceAudioManager.OnEvent", self, self.OnEvent)
    EventSystem.AddEvent("AudienceAudioManager.FadeVolume", self, self.FadeVolume)
    EventSystem.AddEvent("AudienceAudioManager.VolumeUp", self, self.VolumeUp)
    EventSystem.AddEvent("AudienceAudioManager.DestroyAllAudio", self, self.DestroyAllAudio)
    EventSystem.AddEvent("Match_Substitute", self, self.PlaySubstituteAudienceBgAudio)
    EventSystem.AddEvent("Match_PlayerEnterCourt", self, self.PlayEnterCourtAudienceBgAudio)
    EventSystem.AddEvent("OnMatchScoreChange", self, self.OnMatchScoreChange)
    if self.isDemoMatch then
        EventSystem.AddEvent("AudienceAudioManager.DemoMatchPlayAudio", self, self.DemoMatchPlayAudio)
    end
end

function AudienceAudioManager:RemoveEvent()
    EventSystem.RemoveEvent("AudienceAudioManager.OnEvent", self, self.OnEvent)
    EventSystem.RemoveEvent("AudienceAudioManager.FadeVolume", self, self.FadeVolume)
    EventSystem.RemoveEvent("AudienceAudioManager.VolumeUp", self, self.VolumeUp)
    EventSystem.RemoveEvent("AudienceAudioManager.DestroyAllAudio", self, self.DestroyAllAudio)
    EventSystem.RemoveEvent("Match_Substitute", self, self.PlaySubstituteAudienceBgAudio)
    EventSystem.RemoveEvent("Match_PlayerEnterCourt", self, self.PlayEnterCourtAudienceBgAudio)
    EventSystem.RemoveEvent("OnMatchScoreChange", self, self.OnMatchScoreChange)
    if self.isDemoMatch then
        EventSystem.RemoveEvent("AudienceAudioManager.DemoMatchPlayAudio", self, self.DemoMatchPlayAudio)
    end
end

function AudienceAudioManager:OnEvent(eventType, action, volume, playerId, keyframe)
    -- 进攻
    if eventType == AudienceAudioConstants.EventType.OFFENCE then
        self:PlayOffenceAudienceBgAudio(playerId)
    -- 抢断
    elseif eventType == AudienceAudioConstants.EventType.STEAL then
        self:PlayStealAndInterceptAudienceCheerAudio(playerId, keyframe)
    -- 截球
    elseif eventType == AudienceAudioConstants.EventType.INTERCEPT then
        self:PlayStealAndInterceptAudienceCheerAudio(playerId, keyframe)
    -- 进球
    elseif eventType == AudienceAudioConstants.EventType.GOAL then
        self:PlayGoalAudienceCheerAudio(action)
    -- 球未进
    elseif eventType == AudienceAudioConstants.EventType.MISS then
        self:PlayMissAudienceCheerAudio(action)
    -- 射门滑屏
    elseif eventType == AudienceAudioConstants.EventType.MANUAL_SHOOT then
        self:PlayOtherAudio(AudienceAudioConstants.SwipeScreenAudioPath, 0.4)
    -- 踢球
    elseif eventType == AudienceAudioConstants.EventType.KICK then
        self:PlayOtherAudio(AudienceAudioConstants.KickBallAudioPath, volume)
    -- 停止进攻
    elseif eventType == AudienceAudioConstants.EventType.STOP_OFFENCE then
        -- self:StopAudienceCheerAudio()
    -- 犯规
    elseif eventType == AudienceAudioConstants.EventType.FOUL then
        self:PlayFoulAudienceCheerAudio()
    -- 点球
    elseif eventType == AudienceAudioConstants.EventType.PENALTY then
        self:PlayPenaltyAudienceCheerAudio(playerId)
    -- 技能
    elseif eventType == AudienceAudioConstants.EventType.SKILL then
        self:PlaySkillAudienceCheerAudio(playerId)
    end
end

--- 播放开场观众背景音
function AudienceAudioManager:PlayEnterCourtAudienceBgAudio()
    self:PlayAudienceBgAudio6(2)
end

--- 播放观众背景音1
function AudienceAudioManager:PlayAudienceBgAudio(isRandom)
    local bgAudioPath = nil
    if isRandom then
        self.bgAudioIndex = self:RandomItem({1, 3, 4})
        if self.bgAudioIndex <= 2 then
            bgAudioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track10" .. self.bgAudioIndex .. ".wav"
        else
            bgAudioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track10" .. self.bgAudioIndex .. ".mp3"
        end
    else
        if self.bgAudioIndex <= 2 then
            self.bgAudioIndex = 1
            bgAudioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track10" .. self.bgAudioIndex .. ".wav"
        else
            self.bgAudioIndex = self:RandomItem({3, 4})
            bgAudioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track10" .. self.bgAudioIndex .. ".mp3"
        end
    end
    local volume = VOLUME_CONFIG.PLAYER_DEFAULT
    if self.inVolumeFade then
        volume = volume * self.fadeOutVolumeFactor
    end
    self.audienceBgAudioPlayer.PlayAudio(bgAudioPath, volume * VOLUME_CONFIG.VOLUME_RATE)
end

--- 播放观众背景音2
function AudienceAudioManager:PlayAudienceBgAudio2()
    -- 观众歌声播放方式改为每场比赛随机挑选两首，作为该场比赛备选。播放时随机2选1，并随机在3、4、5中随机挑选一个数字作为该首歌曲的连续播放次数，播放完毕后，重复上述挑选歌曲过程。
    local alternativeSong = {}
    local songList = {1, 2, 3, 4, 5, 6}
    local tmpIndex = self:RandomNum(#songList)
    table.insert(alternativeSong, table.remove(songList, tmpIndex))
    tmpIndex = self:RandomNum(#songList)
    table.insert(alternativeSong, table.remove(songList, tmpIndex))

    local loopTimesList = {3, 4, 5}
    self:coroutine(function()
        while true and self.audienceBgAudioPlayer2 ~= nil and self.audienceBgAudioPlayer2 ~= clr.null do
            local audioIndex = self:RandomItem(alternativeSong)
            local bgAudioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track20" .. audioIndex .. ".mp3"
            self.audienceBgAudioPlayer2.PlayAudio(bgAudioPath, VOLUME_CONFIG.PLAYER2_DEFAULT * VOLUME_CONFIG.VOLUME_RATE)
            self.audienceBgAudioPlayer2.loop = true

            local playTime = self:RandomItem(loopTimesList) * self.audienceBgAudioPlayer2.clip.length
            coroutine.yield(UnityEngine.WaitForSeconds(playTime))
        end
    end)
end

--- 播放观众背景音3
function AudienceAudioManager:PlayAudienceBgAudio3()
    local bgAudioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track301.mp3"
    self.audienceBgAudioPlayer3.PlayAudio(bgAudioPath, VOLUME_CONFIG.PLAYER3_DEFAULT * VOLUME_CONFIG.VOLUME_RATE)
    self.audienceBgAudioPlayer3.loop = true
end

--- 播放观众背景音5
function AudienceAudioManager:PlayAudienceBgAudio5(audioIndex)
    if self.lastAudioIndexOnAudioPlayer5 == nil then
        self.lastAudioIndexOnAudioPlayer5 = audioIndex
    else
        if audioIndex ~= 3 and audioIndex ~= 4 and self.lastAudioIndexOnAudioPlayer5 == audioIndex and self.isAudio5Ended == false then
            return
        end
    end
    self.lastAudioIndexOnAudioPlayer5 = audioIndex
    local bgAudioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track50" .. audioIndex .. ".mp3"
    local volume = VOLUME_CONFIG.PLAYER5_DEFAULT
    if self.inVolumeFade then
        volume = volume * self.fadeOutVolumeFactor
    end
    self.audienceBgAudioPlayer5.PlayAudio(bgAudioPath, volume * VOLUME_CONFIG.VOLUME_RATE)
    self.isAudio5Ended = false
end

--- 播放观众背景音6
function AudienceAudioManager:PlayAudienceBgAudio6(audioIndex)
    local bgAudioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track60" .. audioIndex .. ".mp3"
    self.audienceBgAudioPlayer6.PlayAudio(bgAudioPath, VOLUME_CONFIG.PLAYER6_DEFAULT * VOLUME_CONFIG.VOLUME_RATE)
end

--- 播放换人观众背景音
function AudienceAudioManager:PlaySubstituteAudienceBgAudio()
    local audioList = {self:RandomItem({9, 10})}
    self:ResetAudienceCheerAudio(audioList)
    self:PlayAudienceBgAudio6(1)
end

--- 播放比分领先观众背景音
function AudienceAudioManager:PlayOutscoreAudienceBgAudio()
    if self.playerScore > self.opponentScore and self.isAudio5Ended == true then
        local audioIndex = self:RandomItem({3, 4})
        self:PlayAudienceBgAudio5(audioIndex)
    end
end

--- 播放进攻观众背景音
function AudienceAudioManager:PlayOffenceAudienceBgAudio(id)
    if self.playerScore < self.opponentScore then
        if self:RandomNum(10) <= 3 then
            self:PlayAudienceBgAudio5(2)
        end
    elseif self.playerScore - self.opponentScore >= 2 then
        local isPlayer = ___matchUI:isPlayer(id)
        if isPlayer and self:RandomNum(10) <= 4 then
            self:PlayAudienceBgAudio5(2)
        end
    end
end

--- 播放进球观众欢呼声
function AudienceAudioManager:PlayGoalAudienceCheerAudio(action)
    local isPlayer = ___matchUI:isPlayer(action.shooterAthleteId)
    if isPlayer then
        local audioList = {self:RandomItem({1, 2})}
        self:ResetAudienceCheerAudio(audioList)
    else
        if self:RandomNum(10) <= 4 then
            local audioList = {self:RandomItem({3, 4})}
            self:ResetAudienceCheerAudio(audioList)
        end
    end
end

--- 播放未进球观众欢呼声
function AudienceAudioManager:PlayMissAudienceCheerAudio(action)
    local isPlayer = ___matchUI:isPlayer(action.shooterAthleteId)
    local audioList = nil
    if isPlayer then
        audioList = {6}
        if self:RandomNum(10) <= 6 then
            table.insert(audioList, self:RandomItem({9, 10}))
        end
    else
        audioList = {5}
        -- 我方门将将球抱住
        if action.shootResult == ShootResult.Catched and self:RandomNum(10) <= 6 then
            table.insert(audioList, self:RandomItem({9, 10}))
        end
    end
    self:ResetAudienceCheerAudio(audioList)
end

--- 播放犯规观众欢呼声
function AudienceAudioManager:PlayFoulAudienceCheerAudio()
    local audioList = {self:RandomItem({7, 8})}
    self:ResetAudienceCheerAudio(audioList)
end

--- 播放点球观众欢呼声
function AudienceAudioManager:PlayPenaltyAudienceCheerAudio(id)
    local isPlayer = ___matchUI:isPlayer(id)
    if isPlayer then
        local audioList = {self:RandomItem({3, 4})}
        self:ResetAudienceCheerAudio(audioList)
    else
        local audioList = {self:RandomItem({7, 8})}
        self:ResetAudienceCheerAudio(audioList)
    end
end

--- 播放技能观众欢呼声
function AudienceAudioManager:PlaySkillAudienceCheerAudio(id)
    local isPlayer = ___matchUI:isPlayer(id)
    if isPlayer then
        local audioList = {self:RandomItem({3, 4})}
        self:ResetAudienceCheerAudio(audioList)
    end
end

--- 播放观众欢呼声
function AudienceAudioManager:PlayAudienceCheerAudio(audioIndex, volume)
    local audioPath = AudienceAudioConstants.MatchAudioPath .. "audience_track40" .. audioIndex .. ".mp3"
    local isOpen = cache.getLocalData("keySettingsSoundEffectOpen") or 1
    if isOpen == 1 then
        if not volume then
            volume = VOLUME_CONFIG.CHEER_PLAYER_DEFAULT
        end
        if self.inVolumeFade then
            volume = volume * self.fadeOutVolumeFactor
        end

        if self.isCheerFirstAudioEnded and self.isCheerSecondAudioEnded then
            self.isCheerFirstAudioEnded = false
            self.audienceCheerFirstAudioPlayer.PlayAudio(audioPath, volume * VOLUME_CONFIG.VOLUME_RATE)
        else
            if self.isCheerFirstAudioEnded == false and self.isCheerSecondAudioEnded == false then
                if self.isCheerFirstAudioInSwitch then
                    ShortcutExtensions.DOComplete(self.audienceCheerFirstAudioPlayer, true)
                elseif self.isCheerSecondAudioInSwitch then
                    ShortcutExtensions.DOComplete(self.audienceCheerSecondAudioPlayer, true)
                end
            end

            if self.isCheerFirstAudioEnded == false then
                self.isCheerSecondAudioEnded = false
                self.isCheerFirstAudioInSwitch = true
                self.audienceCheerSecondAudioPlayer.PlayAudio(audioPath, volume * VOLUME_CONFIG.VOLUME_RATE)
                local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceCheerFirstAudioPlayer, 0, 1.5)
                local mySequence = DOTween.Sequence()
                TweenSettingsExtensions.SetId(mySequence, "audienceCheerFirstAudioPlayer")
                TweenSettingsExtensions.Append(mySequence, fadeOutTweener)
                TweenSettingsExtensions.AppendCallback(mySequence, function ()
                    self.isCheerFirstAudioInSwitch = false
                    self.audienceCheerFirstAudioPlayer.Stop()  --Lua assist checked flag
                end)
            elseif self.isCheerSecondAudioEnded == false then
                self.isCheerFirstAudioEnded = false
                self.isCheerSecondAudioInSwitch = true
                self.audienceCheerFirstAudioPlayer.PlayAudio(audioPath, volume * VOLUME_CONFIG.VOLUME_RATE)
                local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceCheerSecondAudioPlayer, 0, 1.5)
                local mySequence = DOTween.Sequence()
                TweenSettingsExtensions.SetId(mySequence, "audienceCheerSecondAudioPlayer")
                TweenSettingsExtensions.Append(mySequence, fadeOutTweener)
                TweenSettingsExtensions.AppendCallback(mySequence, function ()
                    self.isCheerSecondAudioInSwitch = false
                    self.audienceCheerSecondAudioPlayer.Stop()  --Lua assist checked flag
                end)
            end
        end
    end
end

--- 重置观众欢呼声
function AudienceAudioManager:ResetAudienceCheerAudio(list)
    self.playeringCheerAudioList = list
    self.playingCheerAudioIndex = 0
    self:PlayNextAudienceCheerAudio()
end

--- 播放下一个观众欢呼声
function AudienceAudioManager:PlayNextAudienceCheerAudio()
    self.playingCheerAudioIndex = self.playingCheerAudioIndex + 1
    local audioIndex = self.playeringCheerAudioList[self.playingCheerAudioIndex]
    if audioIndex ~= nil then
        self:PlayAudienceCheerAudio(audioIndex, 0.85)
    end
end

--- 停止其他的观众欢呼声，播放默认的
function AudienceAudioManager:StopAudienceCheerAudio()

end

function AudienceAudioManager:PlayStealAndInterceptAudienceCheerAudio(id, keyframe)
    local isPlayer = ___matchUI:isPlayer(id)
    local nowPosition = CommentaryManager.GetInstance():GetPlayerPositon(id, keyframe.actionStartFrame.GetPosition())
    if isPlayer then
        if nowPosition[4] and self:RandomNum(10) <= 5 then
            local audioList = {self:RandomItem({3, 4})}
            self:ResetAudienceCheerAudio(audioList)
        end

        if self:RandomNum(10) <= 4 then
            self:PlayAudienceBgAudio5(1)
        end
    end
end

--- 播放其他音频
function AudienceAudioManager:PlayOtherAudio(audioPath, volume)
    if not volume then
        volume = 1
    end
    self.otherAudioPlayer.PlayAudio(audioPath, volume * VOLUME_CONFIG.VOLUME_RATE)
end

--- 停止其他音效
function AudienceAudioManager:StopOtherAudio()
    self.otherAudioPlayer.Stop()  --Lua assist checked flag
end

--- 当比分改变时
function AudienceAudioManager:OnMatchScoreChange(playerScore, opponentScore)
    self.playerScore = playerScore
    self.opponentScore = opponentScore
    self:PlayOutscoreAudienceBgAudio()
end

--- 销毁音频
function AudienceAudioManager:DestroyAllAudio()
    self:RemoveAudioListener()
    DOTween.Kill("audienceBg5")
    DOTween.Kill("audienceCheerFirstAudioPlayer")
    DOTween.Kill("audienceCheerSecondAudioPlayer")
    self:DestroyAudio(self.audienceBgAudioPlayer)
    self:DestroyAudio(self.audienceBgAudioPlayer2)
    self:DestroyAudio(self.audienceBgAudioPlayer3)
    self:DestroyAudio(self.audienceBgAudioPlayer6)
    self:DestroyAudio(self.audienceBgAudioPlayer5)
    self:DestroyAudio(self.audienceCheerFirstAudioPlayer)
    self:DestroyAudio(self.audienceCheerSecondAudioPlayer)
    self:DestroyAudio(self.otherAudioPlayer)
end

function AudienceAudioManager:FadeVolume(targetVolumeFactor, duration)
    local isOpen = cache.getLocalData("keySettingsSoundEffectOpen") or 1
    if isOpen == 1 then
        targetVolumeFactor = targetVolumeFactor or 0
        duration = duration or 1
        self.fadeOutTweenerRunning = true
        self.inVolumeFade = true
        self.fadeOutVolumeFactor = targetVolumeFactor
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer, VOLUME_CONFIG.PLAYER_DEFAULT * targetVolumeFactor, duration)
        local mySequence = DOTween.Sequence()
        TweenSettingsExtensions.SetId(mySequence, "fadeOutTweener")
        TweenSettingsExtensions.Append(mySequence, fadeOutTweener)
        TweenSettingsExtensions.AppendCallback(mySequence, function ()
            self.fadeOutTweenerRunning = false
        end)

        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer2, VOLUME_CONFIG.PLAYER2_DEFAULT * targetVolumeFactor, duration)
        TweenSettingsExtensions.SetId(fadeOutTweener, "fadeOutTweener")
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer3, VOLUME_CONFIG.PLAYER3_DEFAULT * targetVolumeFactor, duration)
        TweenSettingsExtensions.SetId(fadeOutTweener, "fadeOutTweener")
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer6, VOLUME_CONFIG.PLAYER6_DEFAULT * targetVolumeFactor, duration)
        TweenSettingsExtensions.SetId(fadeOutTweener, "fadeOutTweener")
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer5, VOLUME_CONFIG.PLAYER5_DEFAULT * targetVolumeFactor, duration)
        TweenSettingsExtensions.SetId(fadeOutTweener, "fadeOutTweener")
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceCheerFirstAudioPlayer, VOLUME_CONFIG.CHEER_PLAYER_DEFAULT * targetVolumeFactor, duration)
        TweenSettingsExtensions.SetId(fadeOutTweener, "fadeOutTweener")
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceCheerSecondAudioPlayer, VOLUME_CONFIG.CHEER_PLAYER_DEFAULT * targetVolumeFactor, duration)
        TweenSettingsExtensions.SetId(fadeOutTweener, "fadeOutTweener")
    end
end

function AudienceAudioManager:VolumeUp(duration)
    local isOpen = cache.getLocalData("keySettingsSoundEffectOpen") or 1
    if isOpen == 1 then
        duration = duration or 0.5

        if self.fadeOutTweenerRunning then
            DOTween.Kill("fadeOutTweener")
            self.fadeOutTweenerRunning = false
        end

        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer, VOLUME_CONFIG.PLAYER_DEFAULT, duration)
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer2, VOLUME_CONFIG.PLAYER2_DEFAULT, duration)
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer3, VOLUME_CONFIG.PLAYER3_DEFAULT, duration)
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer6, VOLUME_CONFIG.PLAYER6_DEFAULT, duration)
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer5, VOLUME_CONFIG.PLAYER5_DEFAULT, duration)
        local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceCheerFirstAudioPlayer, VOLUME_CONFIG.CHEER_PLAYER_DEFAULT, duration)

        local mySequence = DOTween.Sequence()
        TweenSettingsExtensions.Append(mySequence, fadeOutTweener)
        TweenSettingsExtensions.AppendCallback(mySequence, function ()
            self.inVolumeFade = false
        end)
    end
end

function AudienceAudioManager:DemoMatchPlayAudio(audioList)
    self:ResetAudienceCheerAudio(audioList)
end

function AudienceAudioManager:DestroyAudio(audioPlayer)
    if audioPlayer == nil or audioPlayer == clr.null then
        return
    end
    if audioPlayer.gameObject == nil or audioPlayer.gameObject == clr.null then
        return
    end
    Object.Destroy(audioPlayer.gameObject)
end

function AudienceAudioManager:onDestroy()
    self:RemoveEvent()
end

return AudienceAudioManager
