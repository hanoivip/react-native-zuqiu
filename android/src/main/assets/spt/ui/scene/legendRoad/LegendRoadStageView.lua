local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local UnityEngine = clr.UnityEngine
local EventSystems = UnityEngine.EventSystems
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LegendRoadStageView = class(unity.base, "LegendRoadStageView")

function LegendRoadStageView:ctor()
    self.sptNodes = self.___ex.sptNodes
    EventSystem.AddEvent("LegendRoad_Stage_Levelup_Effect", self, self.StageLevelupEffect)
    self.currentEventSystem = EventSystems.EventSystem.current
end

function LegendRoadStageView:InitView(legendRoadModel)
    self.legendRoadModel = legendRoadModel
    self.capicity = table.nums(self.sptNodes)
end

function LegendRoadStageView:RefreshView()
    self.stageDatas = self.legendRoadModel:GetCurrStageDatas() or {}
    if table.isEmpty(self.stageDatas) then
        for i = 1, self.capicity do
            GameObjectHelper.FastSetActive(self.sptNodes[tostring(i)].gameObject, false)
        end
        return
    end

    local currStageId = self.legendRoadModel:GetCurrStageId()
    local unlockChapter, unlockStage = self.legendRoadModel:GetCardLegendProgress()
    for index, stageData in pairs(self.stageDatas) do
        local spt = self.sptNodes[tostring(index)]
        spt.onStageNodeClick = function(index)
            self:OnStageNodeClick(index)
        end
        local stageId = stageData.idPieceMemory
        spt:InitView(stageData, stageId, unlockStage, unlockChapter)
        spt:SetSelect(tonumber(currStageId) == tonumber(stageId))
    end
end

function LegendRoadStageView:SetStageDatas(stageDatas)
    self.stageDatas = stageDatas
end

function LegendRoadStageView:OnStageNodeClick(index)
    if self.onStageNodeClick and type(self.onStageNodeClick) == "function" then
        self.onStageNodeClick(index)
    end
end

function LegendRoadStageView:StageLevelupEffect(stageId, effectTime)
    local nextStageId = stageId + 1
    local stageNum = self.legendRoadModel:GetStageNum(self.legendRoadModel:GetCurrChapterId())
    if stageId > 0 and stageId < stageNum then
        local nextNodeView = self.sptNodes[tostring(nextStageId)]
        local currentNodeView = self.sptNodes[tostring(stageId)]
        local lineEffect = currentNodeView:GetlineEffect()
        currentNodeView:IsShowLineEffect(true)
        currentNodeView:ResetLineAmount(0)
        nextNodeView:IsShowBallEffect(false)

        local mySequence = DOTween.Sequence()
        local lineInTweener = ShortcutExtensions.DOFillAmount(lineEffect, 1, effectTime / 2)
        TweenSettingsExtensions.SetEase(lineInTweener, Ease.InOutQuad)
        TweenSettingsExtensions.OnComplete(lineInTweener, function ()
            nextNodeView:IsShowBallEffect(true)
            self.currentEventSystem.enabled = true
        end)
        TweenSettingsExtensions.Append(mySequence, lineInTweener)
        local ballInTweener = ShortcutExtensions.DOAnchorPosX(self.gameObject.transform, 0, effectTime / 2, false)
        TweenSettingsExtensions.OnComplete(ballInTweener, function ()
            nextNodeView:IsShowBallEffect(false)
            currentNodeView:IsShowLineEffect(false)
            self.currentEventSystem.enabled = true
        end)
        TweenSettingsExtensions.Append(mySequence, ballInTweener)
    end
end

function LegendRoadStageView:onDestroy()
    EventSystem.RemoveEvent("LegendRoad_Stage_Levelup_Effect", self, self.StageLevelupEffect)
end

return LegendRoadStageView
