local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local ArenaScore = require("data.ArenaScore")
local ArenaReward = require("data.ArenaReward")
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local TweenExtensions = Tweening.TweenExtensions
local ArenaScheduleRewardView = class(unity.base)

function ArenaScheduleRewardView:ctor()
    self.rewardEffectView = self.___ex.rewardEffectView
    self.rank = self.___ex.rank
    self.medalIcon = self.___ex.medalIcon
    self.medelText = self.___ex.medelText
    self.score = self.___ex.score
    self.btnReward = self.___ex.btnReward
    self.rewardText = self.___ex.rewardText
    self.beRecieved = self.___ex.beRecieved
    self.title = self.___ex.title
    self.cup = self.___ex.cup
    self.medalEffectMap = self.___ex.medalEffectMap
    self.medalPosMap = self.___ex.medalPosMap
    self.targetMedal = self.___ex.targetMedal
    self.sweepEffect = self.___ex.sweepEffect

    self.btnReward:regOnButtonClick(function()
        self:OnBtnReward()
    end)
end

function ArenaScheduleRewardView:OnBtnReward()
    if self.clickReward then 
        self.clickReward(self.isRecieved)
    end
end

function ArenaScheduleRewardView:EnterScene()
    EventSystem.AddEvent("ArenaRewardStateChange", self, self.ArenaRewardStateChange)
end

function ArenaScheduleRewardView:ExitScene()
    EventSystem.RemoveEvent("ArenaRewardStateChange", self, self.ArenaRewardStateChange)
end

function ArenaScheduleRewardView:ArenaRewardStateChange(arenaModel)
    self:ChangeState(arenaModel)
    self:ShowMedelEffect()
    self:ShowHonorEffect(arenaModel, true)
end

function ArenaScheduleRewardView:InitView(arenaModel, arenaType)
    GameObjectHelper.FastSetActive(self.sweepEffect, false)
    local ranking = arenaModel:IsMatchRank(arenaType)
    local order = arenaModel:IsMatchOrder(arenaType)
    local rankId = arenaModel:GetMatchRankId(ranking, order)
    local arenaScoreData = ArenaScore[tostring(rankId)]
    self.rank.text = arenaScoreData.rankName
    local score = arenaScoreData.score or 0

    local arenaIndex = ArenaIndexType[arenaType]
    self.cup.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Details/Bytes/Cup" .. arenaIndex .. ".png")
    self.cup:SetNativeSize()
    arenaIndex = arenaIndex > 5 and 5 or arenaIndex
    self.medalIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Medal" .. arenaIndex .. ".png")
    
    local stage = arenaModel:GetMatchStage(arenaType)
    local arenaReward = ArenaReward[tostring(stage)] or {}
    local reward = arenaReward[tostring(rankId)]
    self.medelText.text = "x" .. reward
    self.score.text = tonumber(score) > 0 and "+" .. tostring(score) or tostring(score)
    self.arenaType = arenaType
    self.scoreNum = score
    self:ChangeState(arenaModel)
    self:ShowHonorEffect(arenaModel)
end

function ArenaScheduleRewardView:ShowMedelEffect()
    local arenaIndex = ArenaIndexType[self.arenaType]
    local key = "s" .. (arenaIndex > 5 and 5 or arenaIndex)
    self.medalEffectMap[key].transform.anchoredPosition = Vector2.zero
    local targetPos = self.targetMedal.transform:InverseTransformPoint(self.medalPosMap[key].position)
    local moveInTweener = ShortcutExtensions.DOAnchorPos3D(self.medalEffectMap[key].transform, targetPos, 0.75)
    TweenSettingsExtensions.SetEase(moveInTweener, Ease.OutQuart)
    TweenSettingsExtensions.OnComplete(moveInTweener, function()  --Lua assist checked flag
        GameObjectHelper.FastSetActive(self.sweepEffect, false)
        self.sweepEffect.transform:SetParent(self.medalPosMap[key], false)
        GameObjectHelper.FastSetActive(self.sweepEffect, true)
        GameObjectHelper.FastSetActive(self.medalEffectMap[key].gameObject, false)
    end)
    GameObjectHelper.FastSetActive(self.medalEffectMap[key].gameObject, true)
end

function ArenaScheduleRewardView:ChangeState(arenaModel)
    self.isRecieved = false

    local desc = tonumber(self.scoreNum) > 0 and "arena_winner_desc" or "arena_lose_desc"
    if arenaModel:IsMatchOverNotRecieve(self.arenaType) then 
        self.rewardText.text = lang.trans("collectReward")
    elseif arenaModel:IsMatchOverRecieved(self.arenaType) then
        self.rewardText.text = lang.trans("arena_quite")
        self.isRecieved = true
        desc = "arena_match_end"
    end

    self.title.text = lang.trans(desc)
    GameObjectHelper.FastSetActive(self.beRecieved, self.isRecieved)
end

function ArenaScheduleRewardView:ShowHonorEffect(arenaModel, isPlaying)
    self.rewardEffectView:ShowHonorEffect(arenaModel, self.arenaType, self.scoreNum, isPlaying)
end

return ArenaScheduleRewardView
