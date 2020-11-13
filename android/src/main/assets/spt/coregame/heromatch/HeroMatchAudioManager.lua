local HeroMatchManager = require("coregame.heromatch.HeroMatchManager")
local HeroMatchEvent = HeroMatchManager.HeroMatchEvent
local AudioManager = require("unity.audio")
local AudienceAudioConstants = require("ui.scene.match.AudienceAudioConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")
local EnumType = require("coregame.EnumType")

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local HeroMatchAudioManager = class(unity.base)

function HeroMatchAudioManager:ctor()
    ___heroMatchAudioManager = self

    self.otherAudioPlayer = nil
    self.audienceBgAudioPlayer = nil
    self.audienceCheerAudioPlayer = nil
end

function HeroMatchAudioManager:start()
    self.otherAudioPlayer = AudioManager.GetPlayer("other")
    self.audienceBgAudioPlayer = AudioManager.GetPlayer("audienceBg")
    self.audienceCheerAudioPlayer = AudioManager.GetPlayer("audienceCheer")
    self.commentaryAudioPlayer = AudioManager.GetPlayer("commentary")

    self.audienceBgAudioPlayer.PlayAudio(AudienceAudioConstants.MatchAudioPath .. "audience_track103.mp3", 0.45)
    self.audienceBgAudioPlayer.loop = true
end

function HeroMatchAudioManager:EnterManualOperate()
    -- TODO 暂时取消英雄时刻进入时的音效
    -- UISoundManager.play('Match/heroTime', 1)
end

function HeroMatchAudioManager:InitManualOperate()
    UISoundManager.play("Match/heroMatch_bgm", 0.3, true)
end

function HeroMatchAudioManager:StopUISound()
    UISoundManager.stop()
end

function HeroMatchAudioManager:PlayOffenceCheer()
    self.audienceCheerAudioPlayer.PlayAudio(AudienceAudioConstants.MatchAudioPath .. "audience_track404.mp3", 0.55)
end

function HeroMatchAudioManager:OnManualOperateClick(operateType)
    if operateType == EnumType.ManualOperateType.Pass then
    elseif operateType == EnumType.ManualOperateType.Dribble then
        self:PlayOffenceCheer()
        self:PlayCommentaryClip(3)
    elseif operateType == EnumType.ManualOperateType.Shoot then
    end
end

function HeroMatchAudioManager:OnHeroMatchEvent(eventType)
    if eventType == HeroMatchEvent.pass then
        self.otherAudioPlayer.PlayAudio(AudienceAudioConstants.KickBallAudioPath, 0.15)
    elseif eventType == HeroMatchEvent.long_pass then
        self.otherAudioPlayer.PlayAudio(AudienceAudioConstants.KickBallAudioPath, 0.4)
    elseif eventType == HeroMatchEvent.catch then
        self.catchCounter = self.catchCounter and self.catchCounter + 1 or 1
        if self.catchCounter == 2 then
            self.otherAudioPlayer.PlayAudio(AudienceAudioConstants.KickBallAudioPath, 0.15)
        end
    elseif eventType == HeroMatchEvent.shoot then
        self.otherAudioPlayer.PlayAudio(AudienceAudioConstants.KickBallAudioPath, 0.4)
        self:PlayCommentaryClip(4)
    elseif eventType == HeroMatchEvent.goal then
        --goal audio
        self.audienceCheerAudioPlayer.PlayAudio(AudienceAudioConstants.MatchAudioPath .. "audience_track401.mp3", 0.55)
    elseif eventType == HeroMatchEvent.commentary then
        self.commentaryCounter = self.commentaryCounter and self.commentaryCounter + 1 or 1
        if self.commentaryCounter == 1 then
            self:PlayCommentaryClip(1)
        elseif self.commentaryCounter == 2 then
            self:PlayCommentaryClip(2)
        end
    end
end

function HeroMatchAudioManager:OnHeroMatchEnds()
    local fadeOutTweener = ShortcutExtensions.DOFade(self.audienceCheerAudioPlayer, 0, 3)
    local mySequence = DOTween.Sequence()
    TweenSettingsExtensions.Append(mySequence, fadeOutTweener)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        Object.Destroy(self.otherAudioPlayer.gameObject)
        Object.Destroy(self.audienceBgAudioPlayer.gameObject)
        Object.Destroy(self.audienceCheerAudioPlayer.gameObject)
        ___heroMatchManager:EndHeroMatch()
    end)
    local fadeOutTweener2 = ShortcutExtensions.DOFade(self.audienceBgAudioPlayer, 0, 1.5)
end

function HeroMatchAudioManager:PlayCommentaryClip(idx)
    if idx == 1 then
        self.commentaryAudioPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/Commentary/HeroMatch/counter_1.mp3", 1)
    elseif idx == 2 then
        self.commentaryAudioPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/Commentary/HeroMatch/counter_2.mp3", 1)
    elseif idx == 3 then
        self.commentaryAudioPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/Commentary/HeroMatch/counter_3.mp3", 1)
    elseif idx == 4 then
        self.commentaryAudioPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/Commentary/HeroMatch/counter_4.mp3", 1)
    end
end

return HeroMatchAudioManager