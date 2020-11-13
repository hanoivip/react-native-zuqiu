local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LegendRoadStageNodeView = class(LuaButton, "LegendRoadStageNodeView")

function LegendRoadStageNodeView:ctor()
    LegendRoadStageNodeView.super.ctor(self)
    self.objLine = self.___ex.objLine
    self.lineLocked = self.___ex.lineLocked
    self.lineUnlocked = self.___ex.lineUnlocked
    self.ballLocked = self.___ex.ballLocked
    self.ballUnlocked = self.___ex.ballUnlocked
    self.selected = self.___ex.selected
    self.lineEffect = self.___ex.lineEffect
    self.ballEffectObj = self.___ex.ballEffectObj
    self.ballAnimation = self.___ex.ballAnimation
end

function LegendRoadStageNodeView:GetlineEffect()
    return self.lineEffect
end

function LegendRoadStageNodeView:InitView(stageData, stageId, unlockStage, unlockChapter)
    self.stageId = tonumber(stageId)
    self.stageData = stageData
    self:regOnButtonClick(function()
        self:OnStageNodeClick()
    end)
    local chapterId = stageData.idMemory

    local isUnlock = false
    if tonumber(chapterId) < unlockChapter then
        isUnlock = true
    elseif chapterId == unlockChapter then
        isUnlock = tobool(tonumber(stageId) <= unlockStage)
    end

    GameObjectHelper.FastSetActive(self.ballLocked.gameObject, not isUnlock)
    GameObjectHelper.FastSetActive(self.ballUnlocked.gameObject, isUnlock)

    GameObjectHelper.FastSetActive(self.lineLocked.gameObject, not isUnlock)
    GameObjectHelper.FastSetActive(self.lineUnlocked.gameObject, isUnlock)
end

function LegendRoadStageNodeView:OnStageNodeClick()
    if self.onStageNodeClick and type(self.onStageNodeClick) == "function" then
        self.onStageNodeClick(self.stageId)
    end
end

function LegendRoadStageNodeView:SetSelect(isSelect)
    GameObjectHelper.FastSetActive(self.selected.gameObject, isSelect)
end

function LegendRoadStageNodeView:ResetLineAmount(value)
    self.lineEffect.fillAmount = value
end

function LegendRoadStageNodeView:IsShowLineEffect(show)
    GameObjectHelper.FastSetActive(self.lineEffect.gameObject, show)
end

function LegendRoadStageNodeView:IsShowBallEffect(show)
    GameObjectHelper.FastSetActive(self.ballEffectObj.gameObject, show)
end

return LegendRoadStageNodeView
