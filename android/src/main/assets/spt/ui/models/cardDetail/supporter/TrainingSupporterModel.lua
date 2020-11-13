local TrainingUnlock = require("data.TrainingUnlock")
local TrainingComplete = require("data.TrainingComplete")
local TrainingEffect = require("data.TrainingEffect")
local SupporterType = require("ui.models.cardDetail.supporter.SupporterType")
local Model = require("ui.models.Model")

local TrainingSupporterModel = class(Model, "TrainingSupporterModel")

function TrainingSupporterModel:ctor(supporterModel)
    TrainingSupporterModel.super.ctor(self)
    self.supporterModel = supporterModel
end

function TrainingSupporterModel:Init()
    self.sortTrainingComplete = {}
    for i, v in pairs(TrainingComplete) do
        v.id = tonumber(i)
        table.insert(self.sortTrainingComplete, v)
    end
    table.sort(self.sortTrainingComplete, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
end

function TrainingSupporterModel:InitWithProtocol(supportTraining, selfTraining)
    self:SetSelfTrainingData(selfTraining)
    self:SetSupportTrainingData(supportTraining)
end

function TrainingSupporterModel:SetSelfTrainingData(selfTraining)
    self.selfTraining = selfTraining
    self.selfMaxTrainId = self:GetMaxTrainingId(selfTraining)
end

function TrainingSupporterModel:SetSupportTrainingData(supportTraining)
    self.supportTraining = supportTraining
    local supportMaxTrainId = self:GetMaxTrainingId(supportTraining)
    local supportCardModel = self.supporterModel:GetSupportCardModel()
    self.supportMaxTrainId = self:FixMaxTrainingId(supportTraining, supportMaxTrainId, supportCardModel)
end

-- self card
function TrainingSupporterModel:GetSelfPcid()
    local cardModel = self.supporterModel:GetCardModel()
    local cid = cardModel:GetPcid()
    return cid
end

function TrainingSupporterModel:GetSelfMaxTraining()
    return self.selfMaxTrainId
end

function TrainingSupporterModel:GetFixSelfMaxTraining()
    local cardModel = self.supporterModel:GetCardModel()
    local selfTrainingData = self:GetSelfTraining()
    local selfMaxTrainId = self:GetSelfMaxTraining()
    local fixSelfMaxTrainId = self:FixMaxTrainingId(selfTrainingData, selfMaxTrainId, cardModel)
    return fixSelfMaxTrainId
end

function TrainingSupporterModel:GetSelfTraining()
    return self.selfTraining
end

function TrainingSupporterModel:GetSelfExSkill()
    local selfSkill = {}
    for i, v in pairs(self.selfTraining) do
        local chapter = tostring(i)
        if type(v) == "table" and v.open then
            for stageIndex = 1, 5 do
                local stage = tostring(stageIndex)
                local id = tostring(tonumber(i) * 100 + stageIndex)
                if TrainingEffect[id].skillImprove and self.selfTraining[i][stage] and self.selfTraining[i][stage].finish then
                    local t = {}
                    t.chapter = chapter
                    t.stage = stage
                    table.insert(selfSkill, t)
                end
            end
        end
    end
    table.sort(selfSkill, function(a, b) return tonumber(a.chapter) < tonumber(b.chapter) end)
    return selfSkill
end

-- support card
function TrainingSupporterModel:GetSupportPcid()
    local supportCardModel = self.supporterModel:GetSupportCardModel()
    if supportCardModel then
        local cid = supportCardModel:GetPcid()
        return cid
    end
end

function TrainingSupporterModel:GetSupportMaxTraining()
    return self.supportMaxTrainId
end

function TrainingSupporterModel:GetSupportTraining()
    return self.supportTraining
end

-- 根据助阵卡最高开启章节 对比本卡的转生条件 本卡不符合转生的前一个stage
function TrainingSupporterModel:GetAscendLock()
    local cardModel = self.supporterModel:GetCardModel()
    local ascendNum = cardModel:GetAscend()
    local supportMaxData = self:GetSupportMaxTraining()
    local fixSelfMaxTraining = self:GetFixSelfMaxTraining()
    local sChapter = supportMaxData.chapter

    for i = 1, sChapter do
        local chapter = tostring(i)
        local unLockData = TrainingUnlock[chapter]
        local throughCondition = unLockData.throughCondition
        if throughCondition and throughCondition > ascendNum then
            local selfAscendChapterFinish = self.selfTraining[chapter].open and fixSelfMaxTraining.chapter >= i
            local supportAscendChapterFinish = self.supportTraining[chapter].open and supportMaxData.chapter >= i
            if supportAscendChapterFinish and (not selfAscendChapterFinish) then
                local ascendLock = {}
                ascendLock.chapter = tonumber(chapter) - 1 -- 转生前可达到的章节
                local chapterStr = tostring(ascendLock.chapter)
                local lastChapter = self.supportTraining[chapterStr]["5"]
                local lastFinish = lastChapter and lastChapter.finish
                if lastFinish then
                    ascendLock.stage = 5  -- 转生前可达到的关卡
                else
                    ascendLock.stage = 4  -- 转生前可达到的关卡
                end
                -- 转生后可解锁的最大 章节 和 关卡（从当前章节往后推至下一个转生所需的章节 或者 目前达到的最大章节）
                local maxTraining = self:GetSupportMaxTraining()
                local maxTrainingId = maxTraining.chapter * 100 + maxTraining.stage --目前达到的最大章节
                ascendLock.throughCondition = throughCondition

                local nextThroughChapter = i + 1
                while(TrainingUnlock[tostring(nextThroughChapter)]) do
                    if TrainingUnlock[tostring(nextThroughChapter)].throughCondition then
                        break
                    end
                    nextThroughChapter = nextThroughChapter + 1
                end
                nextThroughChapter = nextThroughChapter - 1
                local throughMaxId = nextThroughChapter * 100 + 5
                if throughMaxId > maxTrainingId then
                    ascendLock.throughChapter = maxTraining.chapter  --转生后解锁的最大章节
                    local skillImprove = TrainingEffect[tostring(maxTrainingId)].skillImprove
                    if skillImprove and maxTraining.stage == 5 then   --转生后解锁的最大关卡
                        ascendLock.throughStage = 4
                    else
                        ascendLock.throughStage = maxTraining.stage
                    end
                else
                    ascendLock.throughChapter = nextThroughChapter
                    ascendLock.throughStage = 5
                end
                return ascendLock
            end
        end
    end
end

-- 根据助阵卡最高开启章节 对比本卡的Ex技能开启条件 区分出 不需要消耗/已消耗/没有消耗 整卡的部分
function TrainingSupporterModel:GetSupportExSkillLock()
    local ascendLock = self:GetAscendLock()
    local maxSupport = self:GetSupportMaxTraining()
    local exSkillOpenList = {}
    for chapter, v in pairs(self.supportTraining) do
        local chapterNum = tonumber(chapter) or 0
        if chapterNum <= maxSupport.chapter and type(v) == "table" and v.open then
            for index = 1, 5 do
                local stage = tostring(index)
                if v[stage] and v[stage].finish then
                    local effectId = tonumber(chapter) * 100 + tonumber(stage)
                    effectId = tostring(effectId)
                    local skillImprove = TrainingEffect[effectId].skillImprove
                    if skillImprove then
                        -- 本卡这一关的特训是否完成
                        local finish = self.selfTraining[chapter] and self.selfTraining[chapter][stage] and self.selfTraining[chapter][stage].finish
                        -- 没完成的情况下 是否消耗了卡牌
                        local consumeCardNum = self.selfTraining[chapter] and self.selfTraining[chapter][stage] and self.selfTraining[chapter][stage].card
                        consumeCardNum = consumeCardNum or 0
                        if consumeCardNum == 0 then
                            -- 本卡这一关的特训 是否已经消耗了卡牌
                            consumeCardNum = self.selfTraining[chapter] and self.selfTraining[chapter].consumeCard and self.selfTraining[chapter].consumeCard[stage]
                            consumeCardNum = consumeCardNum or 0
                        end
                        local needCard = TrainingComplete[effectId].card or 0
                        local isConsumeCard = needCard > 0 and consumeCardNum >= needCard
                        if not finish and (needCard == 0 or isConsumeCard) then
                            finish = true
                        end
                        local tId = tonumber(chapter) * 100 + tonumber(stage)
                        local open = tobool(finish and (needCard == 0 or isConsumeCard))
                        local t = {}
                        t.chapter = chapter
                        t.stage = stage
                        t.cardNum = needCard
                        t.finish = finish  -- 可用
                        t.open = open  -- 不可用 消耗整卡限制
                        if ascendLock then
                            local ascendId = tonumber(ascendLock.chapter) * 100 + tonumber(ascendLock.stage)
                            t.throughCondition = ascendLock.throughCondition
                            t.close = ascendId < tId -- 不可用 转生限制 优先级比消耗整卡高
                        else
                            t.close = false
                        end
                        table.insert(exSkillOpenList, t)
                    end
                end
            end
        end
    end
    table.sort(exSkillOpenList, function(a, b) return tonumber(a.chapter) < tonumber(b.chapter) end)
    return exSkillOpenList
end

-- 助阵卡实际能开到的章节
-- 此章节之前的Ex技能 根据是否已消耗整卡 开启/（锁定）消耗整卡后开启
-- 此章节之后的Ex技能 全部锁定为转生后开启
function TrainingSupporterModel:GetSupportMinTraining()
    local ascendLockData = self:GetAscendLock()
    local supportMaxData = self:GetSupportMaxTraining()
    local exSkillList = self:GetSupportExSkillLock()
    local minChapter = supportMaxData.chapter
    local minStage = supportMaxData.stage

    -- 转生限制
    if ascendLockData then
        local aChapter = tonumber(ascendLockData.chapter)
        local aStage = tonumber(ascendLockData.stage)
        minChapter = aChapter
        minStage = aStage
    end

    -- 特殊情况 当最后的一关为第五关的时候 判断此关技能是否开放 不开放的话 回退一关
    if minStage == 5 then
        local effectId = tonumber(minChapter) * 100 + tonumber(minStage)
        local isHasSkill = TrainingEffect[tostring(effectId)].skillImprove
        if isHasSkill then
            local isEndSkillClose = true
            for i, v in ipairs(exSkillList) do
                local tId = tonumber(v.chapter) * 100 + tonumber(v.stage)
                if effectId == tId and v.open and not v.close then
                    isEndSkillClose = false
                end
            end
            if isEndSkillClose then
                minStage = 4
            end
        end
    end
    return {chapter = minChapter , stage = minStage}
end

-- other
function TrainingSupporterModel:GetMaxTrainingType()
    local maxSelf = self:GetFixSelfMaxTraining()
    local maxSupport = self:GetSupportMaxTraining()
    maxSelf = tonumber(maxSelf.chapter) * 100 + tonumber(maxSelf.stage)
    maxSupport = tonumber(maxSupport.chapter) * 100 + tonumber(maxSupport.stage)
    if maxSelf < maxSupport then
        return SupporterType.StType.SupportCard
    else
        return SupporterType.StType.SelfCard
    end
end

function TrainingSupporterModel:GetSupportModel()
    return self.supporterModel
end

function TrainingSupporterModel:SetSelectTrainingType(trainingType)
    self.trainingType = trainingType
end

function TrainingSupporterModel:GetSelectTrainingType()
    if not self.trainingType then
        local maxTraining = self:GetFixSelfMaxTraining()
        local isTrainingClose = maxTraining.chapter and maxTraining.chapter <= 0
        if isTrainingClose then
            self.trainingType = SupporterType.StType.SelfCard
        else
            local trainingType = self:GetMaxTrainingType()
            self:SetSelectTrainingType(trainingType)
        end
    end
    return self.trainingType
end

function TrainingSupporterModel:GetCurTrainingInfo()
    if self:GetSelectTrainingType() == SupporterType.StType.SelfCard then
        local trainingInfo = {}
        local selfData = self:GetSelfTraining() or {}
        local trainId = selfData.trainId or 0
        local stage = selfData[tostring(trainId)] and selfData[tostring(trainId)].subId or 0
        stage = math.clamp(stage - 1, 0, stage - 1)
        trainingInfo.chapter = trainId
        trainingInfo.stage = stage
        return trainingInfo
    else
        return self:GetSupportMinTraining()
    end
end

function TrainingSupporterModel:GetMaxTrainingId(trainingData)
    local trainingOpenList = {}
    for chapterIndex, value in pairs(trainingData) do
        if type(value) == "table" and value.open then
            local tChapter = tonumber(chapterIndex)
            for stageIndex = 1, 5 do
                local stageStr = tostring(stageIndex)
                local stageData = trainingData[chapterIndex][stageStr]
                if stageData and stageData.finish then
                    local finishId = tChapter * 100 + stageIndex
                    table.insert(trainingOpenList, finishId)
                end
            end
        end
    end
    local chapter = -1
    local stage = -1
    if next(trainingOpenList) then
        table.sort(trainingOpenList, function(a,b) return a > b end)
        local stageData = TrainingComplete[tostring(trainingOpenList[1])]
        chapter = stageData.idTraining
        stage = stageData.idMssionOrder
    end

    -- 第一关允许1-0特殊存在
    if trainingData["1"] and trainingData["1"].open and trainingData["1"]["1"] and (not trainingData["1"]["1"].finish) then
        chapter = 1
        stage = 0
    end
    return {chapter = chapter, stage = stage}
end


-- 特殊情况--
-- 卡牌转生还原后 特训的进度时不会被还原的
-- 但是 在球员助阵功能中 特训的最大进度 要求是要求转生的那一关
function TrainingSupporterModel:FixMaxTrainingId(trainingData, maxTrainingId, cardModel)
    local mTrainingId = clone(maxTrainingId)
    local ascendNum = cardModel:GetAscend()
    local mChapter = mTrainingId.chapter
    for i = 1, mChapter do
        local index = tostring(i)
        local throughCondition = TrainingUnlock[index].throughCondition
        if throughCondition and throughCondition > ascendNum then
            mTrainingId.chapter = i - 1
            local fixChapterStr = tostring(mTrainingId.chapter)
            local lastStageFinish = trainingData[fixChapterStr]["5"] and trainingData[fixChapterStr]["5"].finish
            if lastStageFinish then
                mTrainingId.stage = 5
            else
                mTrainingId.stage = 4
            end
            break
        end
    end
    return mTrainingId
end

return TrainingSupporterModel
