local Model = require("ui.models.Model")
local Letter = require("data.Letter")
local QuestBase = require("data.QuestBase")
local QuestTeam = require("data.QuestTeam")
local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")

-- 球员信函数据模型
local PlayerLetterItemModel = class(Model, "PlayerLetterItemModel")

function PlayerLetterItemModel:ctor(itemData)
    -- 信函数据
    self.itemData = itemData
    self.super.ctor(self)
end

function PlayerLetterItemModel:Init()
    self.itemData.staticData = Letter[tostring(self:GetID())]
    self.itemData.conditionSum = 0
    self.itemData.completedConditionSum = 0
    self.itemData.finishCondition = {}
    local staticFinishCondition = self.itemData.staticData.finishCondition

    -- 如果有章节通关条件
    if staticFinishCondition.journey3 ~= nil then
        self.itemData.conditionSum = self.itemData.conditionSum + #staticFinishCondition.journey3
        self.itemData.finishCondition.journey3 = {}
        for i, chapterId in ipairs(staticFinishCondition.journey3) do
            self.itemData.finishCondition.journey3[chapterId] = {
                id = chapterId,
                staticData = QuestBase[chapterId],
                isChapter = true,
                isFinished = false,
            }
        end
    end

    -- 如果有关卡通关条件
    if staticFinishCondition.quest ~= nil then
        self.itemData.conditionSum = self.itemData.conditionSum + #staticFinishCondition.quest
        self.itemData.finishCondition.quest = {}
        for i, stageId in ipairs(staticFinishCondition.quest) do
            self.itemData.finishCondition.quest[stageId] = {
                id = stageId,
                staticData = QuestTeam[stageId],
                isChapter = false,
                isFinished = false,
            }
        end
    end

    -- 如果有卡牌收集条件
    if staticFinishCondition.card ~= nil then
        self.itemData.conditionSum = self.itemData.conditionSum + #staticFinishCondition.card
        self.itemData.finishCondition.card = {}
        for i, cardId in ipairs(staticFinishCondition.card) do
            self.itemData.finishCondition.card[cardId] = {
                id = cardId,
                isFinished = false,
            }
        end
    end

    -- 已达成的章节通关条件
    if self.itemData.cond.journey3 ~= nil then
        for chapterId, timestamp in pairs(self.itemData.cond.journey3) do
            self.itemData.finishCondition.journey3[chapterId].isFinished = true
            self.itemData.completedConditionSum = self.itemData.completedConditionSum + 1
        end
    end

    -- 已达成的关卡通关条件
    if self.itemData.cond.quest ~= nil then
        for stageId, timestamp in pairs(self.itemData.cond.quest) do
            if self.itemData.finishCondition.quest[stageId] then
                self.itemData.finishCondition.quest[stageId].isFinished = true
                self.itemData.completedConditionSum = self.itemData.completedConditionSum + 1
            end
        end
    end

    -- 已达成的卡牌收集条件
    if self.itemData.cond.card ~= nil then
        for cardId, timestamp in pairs(self.itemData.cond.card) do
            self.itemData.finishCondition.card[cardId].isFinished = true
            self.itemData.completedConditionSum = self.itemData.completedConditionSum + 1
        end
    end

    self:SetState(self:GetState())
end

--- 获取信件ID
-- @return number
function PlayerLetterItemModel:GetID()
    return self.itemData.ID
end

--- 获取静态数据
-- @return table
function PlayerLetterItemModel:GetStaticData()
    return self.itemData.staticData
end

--- 获取要完成的条件总数
-- @return number
function PlayerLetterItemModel:GetConditionSum()
    return self.itemData.conditionSum
end

--- 获取已完成的条件总数
-- @return number
function PlayerLetterItemModel:GetCompletedConditionSum()
    return self.itemData.completedConditionSum
end

--- 获取要完成的条件
-- @return table
function PlayerLetterItemModel:GetFinishCondition()
    return self.itemData.finishCondition
end

--- 获取信件阅读状态
-- @return number
function PlayerLetterItemModel:GetReadState()
    return self.itemData.read
end

function PlayerLetterItemModel:SetShow()
    self.itemData.hasShow = true
end

function PlayerLetterItemModel:GetShow()
    return self.itemData.hasShow
end

--- 设置信件阅读状态
-- @param readState 信件阅读状态，参考PlayerLetterConstants.LetterReadState
function PlayerLetterItemModel:SetReadState(readState)
    self.itemData.read = tonumber(readState)
end

--- 获取信件状态
-- @return PlayerLetterConstants.LetterState
function PlayerLetterItemModel:GetState()
    return self.itemData.state
end

--- 设置信件状态
-- @param state 信件状态，参考PlayerLetterConstants.LetterState
function PlayerLetterItemModel:SetState(state)
    self.itemData.state = tonumber(state)
end

return PlayerLetterItemModel