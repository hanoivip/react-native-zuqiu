local Model = require("ui.models.Model")
local QuestDesc = require("data.QuestDesc")
local QuestConstants = require("ui.scene.quest.QuestConstants")

local QuestPlotModel = class(Model)

function QuestPlotModel:ctor(questId, showPos)
    self.questId = questId
    self.showPos = showPos
    self.curStep = nil
end

function QuestPlotModel:GetQuestId()
    return self.questId
end

function QuestPlotModel:GetShowPos()
    return self.showPos
end

function QuestPlotModel:GetTextType()
    local plotInfo = self:GetPlotInfoWithCurStep()
    if plotInfo then
        return plotInfo.textType
    end
    return nil
end

function QuestPlotModel:GetEmoji()
    local plotInfo = self:GetPlotInfoWithCurStep()
    if plotInfo then
        return plotInfo.emoji
    end
    return nil
end

function QuestPlotModel:GetText()
    local plotInfo = self:GetPlotInfoWithCurStep()
    if plotInfo then
        return plotInfo.text
    end
    assert(false)
end

function QuestPlotModel:GetPlotInfoWithCurStep()
    for questId, showPosTable in pairs(QuestDesc) do
        if questId == self.questId then
            for showPos, plotTable in pairs(showPosTable) do
                if tonumber(showPos) == self.showPos then
                    for i, plotInfo in ipairs(plotTable) do
                        if plotInfo.ID == self.questId .. "_" .. tostring(self.curStep) then
                            return plotInfo
                        end
                    end
                end
            end
        end
    end
    assert(false)
end

function QuestPlotModel:GetCurStep()
    return self.curStep
end

function QuestPlotModel:GetMinStep()
    if self.showPos == QuestConstants.QuestPlotShowPos.MATCH_STAGE_BEFORE then
        return 1
    elseif self.showPos == QuestConstants.QuestPlotShowPos.MATCH_STAGE_AFTER then
        return self:GetMaxStepWithMatchStageBefore() + 1
    end
end

function QuestPlotModel:GetMaxStep()
    for questId, showPosTable in pairs(QuestDesc) do
        if questId == self.questId then
            for showPos, plotTable in pairs(showPosTable) do
                if tonumber(showPos) == self.showPos then
                    if self.showPos == QuestConstants.QuestPlotShowPos.MATCH_STAGE_BEFORE then
                        return #plotTable
                    elseif self.showPos == QuestConstants.QuestPlotShowPos.MATCH_STAGE_AFTER then
                        return self:GetMaxStepWithMatchStageBefore() + #plotTable
                    end
                end
            end
        end
    end
    assert(false)
end

function QuestPlotModel:GetMaxStepWithMatchStageBefore()
    for questId, showPosTable in pairs(QuestDesc) do
        if questId == self.questId then
            for showPos, plotTable in pairs(showPosTable) do
                if tonumber(showPos) == QuestConstants.QuestPlotShowPos.MATCH_STAGE_BEFORE then
                    return #plotTable
                end
            end
        end
    end
    return 0
end

function QuestPlotModel:GetNextStep()
    local curStep = self:GetCurStep()
    local maxStep = self:GetMaxStep()
    local nextStep = curStep + 1
    if nextStep < maxStep then
        return nextStep
    end
    return maxStep
end

function QuestPlotModel:SetCurStep()
    if not self.curStep then
        self.curStep = self:GetMinStep()
    else
        self.curStep = self:GetNextStep()
    end
end

function QuestPlotModel:GetHasStageAfter()
    for questId, showPosTable in pairs(QuestDesc) do
        if questId == self.questId then
            for showPos, plotTable in pairs(showPosTable) do
                if tonumber(showPos) == QuestConstants.QuestPlotShowPos.MATCH_STAGE_AFTER then
                    return true
                end
            end
        end
    end
end

function QuestPlotModel:SetShowPos(showPos)
    self.showPos = showPos
end

return QuestPlotModel