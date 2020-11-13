local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local QuestDesc = require("data.QuestDesc")

local QuestPlotManager = {}

function QuestPlotManager.Show(questPlotModel, completedCallBack)
    if QuestPlotManager.CheckQuestPlotExisted(questPlotModel) then
        local curStep = questPlotModel:GetCurStep()
        local maxStep = questPlotModel:GetMaxStep()
        if not curStep or curStep < maxStep then
            questPlotModel:SetCurStep()
            QuestPlotManager.Init(questPlotModel, completedCallBack)
        else
            QuestPlotManager.RemoveLastPlot()
            if completedCallBack and type(completedCallBack) == "function" then
                completedCallBack()
            end
        end
    end
end

function QuestPlotManager.Init(questPlotModel, completedCallBack)
    local objs = QuestPlotManager.ShowPlot(questPlotModel, completedCallBack)
    QuestPlotManager.RemoveLastPlot()
    QuestPlotManager.SetLastPlot(objs)
end

function QuestPlotManager.ShowPlot(questPlotModel, completedCallBack)
    local objs = { }
    local prefabName = questPlotModel:GetTextType()
    if prefabName ~= "" then
        local questPlotDialog, questPlotView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Quest/QuestPlot/" .. prefabName .. ".prefab")
        if questPlotView then
            questPlotView:InitView(questPlotModel, completedCallBack)
        end
        table.insert(objs, questPlotDialog)
    end
    return objs
end

function QuestPlotManager.SetLastPlot(objs)
    cache.setGlobalTempData(objs, "QuestPlotLastStep")
end

function QuestPlotManager.RemoveLastPlot()
    local lastObjs = cache.removeGlobalTempData("QuestPlotLastStep")
    if lastObjs and lastObjs ~= clr.null then
        clr.coroutine(function()
            -- unity.waitForNextEndOfFrame()
            if lastObjs and lastObjs ~= clr.null then
                for i, obj in ipairs(lastObjs) do
                    Object.Destroy(obj)
                end
            end
        end)
    end
end

-- 检查关卡是否需要显示剧情
function QuestPlotManager.CheckQuestPlotExisted(questPlotModel)
    for questId, showPosTable in pairs(QuestDesc) do
        if questId == questPlotModel:GetQuestId() then
            for showPos, v in pairs(showPosTable) do
                if tonumber(showPos) == questPlotModel:GetShowPos() then
                    return true
                end
            end
        end
    end
    return false
end

return QuestPlotManager