local Model = require("ui.models.Model")
local Vector2 = clr.UnityEngine.Vector2
-- 主线副本数据模型
local QuestPageViewModel = class(Model, "QuestPageViewModel")

function QuestPageViewModel:ctor()
    -- 视图数据
    self.viewData = nil
    -- 要舍弃的视图数据，主要用于从大卡进入主线的情况
    self.viewDiscardData = nil
    self.model = nil
    self.super.ctor(self)
end

function QuestPageViewModel:Init()
    self.viewData = cache.getQuestPageViewInfo()
    if self.viewData == nil then
        self.viewData = {}
    end
    self:SetViewDiscardData(cache.getQuestPageViewDiscardInfo())
end

--- QuestInfoModel
-- @return QuestInfoModel
function QuestPageViewModel:GetModel()
    return self.model
end

--- 设置QuestInfoModel，使ViewModel可以获取到数据
-- @param model QuestInfoModel
function QuestPageViewModel:SetModel(model)
    self.model = model
end

function QuestPageViewModel:SetViewDiscardData(viewDiscardData)
    self.viewDiscardData = viewDiscardData or {}
    cache.setQuestPageViewDiscardInfo(self.viewDiscardData)
end

function QuestPageViewModel:GetViewDiscardData()
    return self.viewDiscardData
end

--- 设置比赛关卡Id
-- @param stageId 关卡Id
function QuestPageViewModel:SetMatchStageId(stageId)
    local stageInfoModel = self.model:GetStageInfoModelById(stageId)
    self.viewData.matchStageId = stageId
    self.viewData.matchStageIsCleared = stageInfoModel:CheckStageCleared()
    self.viewData.matchStageIsSpecial = stageInfoModel:HasSpecialConditions()
    cache.setQuestPageViewInfo(self.viewData)
    self:InitAutoSkipQuestStageState()
end

--- 获取比赛关卡Id
function QuestPageViewModel:GetMatchStageId()
    return self.viewData.matchStageId, self.viewData.matchStageIsCleared, self.viewData.matchStageIsSpecial
end

--- 设置最后打开的章节Id
-- @param chapterId 章节Id
function QuestPageViewModel:SetLastOpenedChapterId(chapterId)
    if self:GetDataStorageType() then
        self.viewDiscardData.lastOpenedChapterId = chapterId
        cache.setQuestPageViewDiscardInfo(self.viewDiscardData)
    else
        self.viewData.lastOpenedChapterId = chapterId
        cache.setQuestPageViewInfo(self.viewData)
    end
end

--- 获取最后打开的章节Id
-- @return string
function QuestPageViewModel:GetLastOpenedChapterId()
    if self:GetDataStorageType() then
        return self.viewDiscardData.lastOpenedChapterId
    else
        return self.viewData.lastOpenedChapterId
    end
end

--- 设置关卡Id
-- @param stageId 关卡Id
function QuestPageViewModel:SetStageId(stageId)
    if self:GetDataStorageType() then
        self.viewDiscardData.stageId = stageId
        cache.setQuestPageViewDiscardInfo(self.viewDiscardData)
    else
        self.viewData.stageId = stageId
        cache.setQuestPageViewInfo(self.viewData)
    end
end

function QuestPageViewModel:GetStageId()
    if self:GetDataStorageType() then
        if self.viewDiscardData.stageId == nil then
            self:ResetStageIdOnUnlockStage()
        end
        return self.viewDiscardData.stageId
    else
        if self.viewData.stageId == nil then
            self:ResetStageIdOnUnlockStage()
        end
        return self.viewData.stageId
    end
end

--- 当解锁新的关卡时重置滚动位置
function QuestPageViewModel:ResetStageIdOnUnlockStage()
    local lastChapterId = self.model:GetLastChapterId()
    local lastStageId = self.model:GetLastStageIdByChapterId(lastChapterId)
    self:SetStageId(lastStageId)
    self:SetLastOpenedChapterId(lastChapterId)
end

--- 设置画布尺寸
-- @param questScrollerWidth 画布尺寸，Vector2
function QuestPageViewModel:SetQuestScrollerWidth(questScrollerWidth)
    self.viewData.questScrollerWidth = questScrollerWidth
    cache.setQuestPageViewInfo(self.viewData)
end

--- 获取画布尺寸
-- @return Vector2
function QuestPageViewModel:GetQuestScrollerWidth()
    return self.viewData.questScrollerWidth or 1000
end

--- 设置数据存储方式
-- @param isDiscard 是否会被舍弃
function QuestPageViewModel:SetDataStorageType(isDiscard)
    self.viewData.isDiscard = isDiscard
    cache.setQuestPageViewInfo(self.viewData)
end

--- 获取数据存储方式
function QuestPageViewModel:GetDataStorageType()
    return self.viewData.isDiscard or false
end

--- 更新副本协议数据
-- @param updateData 更新数据
function QuestPageViewModel:UpdateProtocolData(updateData)
    local lastChapterIndex = self.model:GetLastChapterIndex()
    local lastStageIndex = self.model:GetLastStageIndexByChapterIndex(lastChapterIndex)
    self.model:UpdateProtocolData(updateData)
    local newLastChapterIndex = self.model:GetLastChapterIndex()
    if newLastChapterIndex ~= lastChapterIndex then
        self:ResetStageIdOnUnlockStage()
    else
        local newLastStageIndex = self.model:GetLastStageIndexByChapterIndex(lastChapterIndex)
        if lastStageIndex ~= newLastStageIndex then
            self:ResetStageIdOnUnlockStage()
        end
    end
end

-- 存储前五关通关状态，用来标识是否需要弹出饮水机并自动跳过该场比赛
function QuestPageViewModel:InitAutoSkipQuestStageState()
    local autoSkipStagesState = {}
    for i = 1, 5 do
        local stageId = "Q10" .. tostring(i)
        local infoModel = self.model:GetStageInfoModelById(stageId)
        local isClear = infoModel:CheckStageCleared()
        -- 通关后不再引导跳过
        autoSkipStagesState[stageId] = not isClear
    end
    cache.setAutoSkipQuestStageStateList(autoSkipStagesState)
end

-- 回到主页按钮是否显示
function QuestPageViewModel:IsHomeBtnShow()
    return self:GetDataStorageType()
end

return QuestPageViewModel