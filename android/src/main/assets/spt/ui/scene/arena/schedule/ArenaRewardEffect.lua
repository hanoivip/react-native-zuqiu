local UnityEngine = clr.UnityEngine
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local EventSystems = UnityEngine.EventSystems
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local WaitForSeconds = UnityEngine.WaitForSeconds
local Color = UnityEngine.Color
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaRewardEffect = class(unity.base)

function ArenaRewardEffect:ctor()
    self.animator = self.___ex.animator
    self.levelRect = self.___ex.levelRect
    self.stageIcon1 = self.___ex.stageIcon1
    self.stageIcon2 = self.___ex.stageIcon2
    self.starMap = self.___ex.starMap
    self.starAnimatorMap = self.___ex.starAnimatorMap
    self.starEffectMap = self.___ex.starEffectMap
    self.gradeText = self.___ex.gradeText
    self.effect = self.___ex.effect
    self.starText = self.___ex.starText
end

function ArenaRewardEffect:ShowHonorEffect(arenaModel, arenaType, scoreNum, isPlaying)
    local currentScore = arenaModel:GetAreaScore(arenaType)
    if isPlaying then 
        local currentEventSystem = EventSystems.EventSystem.current
        currentEventSystem.enabled = false
        self.animator:Play("ArenaScheduleLevel", 0, 0)
        if self.scoreCor then
            self:StopCoroutine(self.scoreCor)
        end
        self.scoreCor = self:coroutine(function()
            coroutine.yield(WaitForSeconds(1))
            self.isScorePlaying = true
            local finalScore = currentScore + scoreNum
            if finalScore < 1 then finalScore = 1 end
            local stage, star, openStar, minStage, currentMiniStage = arenaModel:GetAreaState(currentScore)
            self:ShowStarEffect(arenaModel, currentScore, finalScore, currentMiniStage)
            while self.isScorePlaying do
                coroutine.yield()
            end
            local stage, star, openStar, minStage = arenaModel:GetAreaState(finalScore)
            if stage then
                self.stageIcon1.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Team" .. stage .. ".png")
                self.stageIcon2.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Mid_Team" .. stage .. ".png")
                self.stageIcon2:SetNativeSize()
            end
            self.animator:Play("ArenaScheduleLevel3", 0, 0)
            coroutine.yield(WaitForSeconds(0.8))
            self:ShowScoreState(arenaModel, finalScore)
            self.scoreCor = nil
            currentEventSystem.enabled = true
        end)
    elseif arenaModel:IsMatchOverNotRecieve(arenaType) then
        self:ShowScoreState(arenaModel, currentScore)
    elseif arenaModel:IsMatchOverRecieved(arenaType) then
        currentScore = currentScore + scoreNum
        self:ShowScoreState(arenaModel, currentScore)
    end

    self.animator.enabled = isPlaying
    self.levelRect.anchoredPosition = isPlaying and Vector2(0, 0) or Vector2(-189.9, 0)
    self.levelRect.localScale = isPlaying and Vector3(3, 3, 1) or Vector3(1, 1, 1)
    GameObjectHelper.FastSetActive(self.effect, isPlaying)
end

-- currentMiniStage 判断段位变化
local textAnimationDuration = 0.4
function ArenaRewardEffect:ShowStarEffect(arenaModel, currentScore, finalScore, currentMiniStage)
    if currentScore == finalScore then 
        self.isScorePlaying = false
        return 
    end
    local changeScore = finalScore - currentScore
    self:coroutine(function()
        local starAnimationName
        if changeScore > 0 then
            currentScore = currentScore + 1
            starAnimationName = "ArenaScheduleLevelStar"
        elseif changeScore < 0 then
            starAnimationName = "ArenaScheduleLevelStar2"
        end

        local stage, star, openStar, minStage, miniStage = arenaModel:GetAreaState(currentScore)
        if miniStage == currentMiniStage and tonumber(stage) >= ArenaHelper.StageType.StoryStage then
            local tweenerX = ShortcutExtensions.DOScaleX(self.starText.gameObject.transform, 0, textAnimationDuration)
            TweenSettingsExtensions.From(tweenerX)
            TweenSettingsExtensions.SetEase(tweenerX, Ease.OutBack)
            local tweenerY = ShortcutExtensions.DOScaleY(self.starText.gameObject.transform, 0, textAnimationDuration)
            TweenSettingsExtensions.From(tweenerY)
            TweenSettingsExtensions.SetEase(tweenerY, Ease.OutBack)

            if changeScore > 0 then
                self.starText.text = tostring(minStage)
            elseif changeScore < 0 then
                currentScore = currentScore - 1
                self.starText.text = tostring(minStage - 1)
            end
            TweenSettingsExtensions.OnComplete(tweenerY, function()  --Lua assist checked flag
                self:ShowStarEffect(arenaModel, currentScore, finalScore, miniStage)
            end)
            return
        end

        if miniStage == currentMiniStage then
            local nextIndex = star
            local starAnimator = self.starAnimatorMap["s" .. nextIndex]
            starAnimator.enabled = true
            GameObjectHelper.FastSetActive(self.starEffectMap["s" .. nextIndex], true)
            starAnimator:Play(starAnimationName, 0, 0)
            coroutine.yield(WaitForSeconds(0.3))
            if changeScore < 0 then
                currentScore = currentScore - 1
            end
            self:ShowStarEffect(arenaModel, currentScore, finalScore, miniStage)
        else
            GameObjectHelper.FastSetActive(self.effect, true)
            self.starText.text = ""
            self.animator:Play("ArenaScheduleLevel2", 0, 0)
            for k, v in pairs(self.starMap) do
                local index = tonumber(string.sub(k, 2))
                local starData = ArenaHelper.GetStarPos[tostring(openStar)]
                local isOpen = starData and tobool(index <= openStar)
                if isOpen then
                    local pos = starData[index]
                    v.gameObject.transform.anchoredPosition = Vector2(pos.x, pos.y)
                    self.starAnimatorMap["s" .. index].enabled = false
                    if changeScore > 0 then
                        v.interactable = false
                    elseif changeScore < 0 then
                        local isShow = tobool(index <= star)
                        v.interactable = isShow
                    end
                end
                GameObjectHelper.FastSetActive(v.gameObject, isOpen)
            end
            local preScore, nextScore
            if changeScore > 0 then
                preScore = currentScore - 1
                nextScore = preScore
            elseif changeScore < 0 then
                preScore = currentScore + 1
                nextScore = currentScore
            end

            local preStage, preStar, preOpenStar, preMinStage, preMiniStage = arenaModel:GetAreaState(preScore)
            if stage then
                self.stageIcon1.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Team" .. preStage .. ".png")
                self.stageIcon2.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Team" .. stage .. ".png")
            end
            coroutine.yield(WaitForSeconds(0.8))
            self:ShowStarEffect(arenaModel, nextScore, finalScore, miniStage)
        end
    end)
end

function ArenaRewardEffect:ShowScoreState(arenaModel, currentScore)
    GameObjectHelper.FastSetActive(self.effect, false)
    self.starText.text = ""
    local stage, star, openStar, minStage = arenaModel:GetAreaState(currentScore)
    for k, v in pairs(self.starMap) do
        local index = tonumber(string.sub(k, 2))
        local starData = ArenaHelper.GetStarPos[tostring(openStar)]
        local isOpen = starData and tobool(index <= openStar)
        if isOpen then
            local pos = starData[index]
            v.gameObject.transform.anchoredPosition = Vector2(pos.x, pos.y)
            local isShow = tobool(index <= star)
            self.starAnimatorMap["s" .. index].enabled = false
            v.interactable = isShow
            GameObjectHelper.FastSetActive(self.starEffectMap["s" .. index], false)
        end
        GameObjectHelper.FastSetActive(v.gameObject, isOpen)
    end
    local minStageNum, minStageDesc = "", ""
    if stage then
        self.stageIcon1.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Team" .. stage .. ".png")
        self.stageIcon2.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Mid_Team" .. stage .. ".png")
        self.stageIcon2:SetNativeSize()
        local minStagePos = ArenaHelper.GetMinStagePos[tostring(stage)]
        if minStagePos then
            if stage < ArenaHelper.StageType.StoryStage then 
                minStageDesc = lang.transstr("reduce_num", minStage) 
            else
                minStageDesc = lang.transstr("star_num", minStage) 
            end
        end
    end
    self.gradeText.text = "(" .. arenaModel:GetGradeName(stage) .. minStageDesc .. ")"
end

return ArenaRewardEffect
