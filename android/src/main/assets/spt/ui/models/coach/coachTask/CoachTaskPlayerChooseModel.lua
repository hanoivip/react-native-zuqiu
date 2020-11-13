local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local CoachMissionDetail = require("data.CoachMissionDetail")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CoachTaskHelper = require("ui.scene.coach.coachTask.CoachTaskHelper")
local Model = require("ui.models.Model")

local CoachTaskPlayerChooseModel = class(Model, "CoachTaskPlayerChooseModel")

-- 排序函数
local function StartOrderComp(aModel, bModel)
    local aQuality = tonumber(aModel:GetCardQuality())
    local bQuality = tonumber(bModel:GetCardQuality())
    return aQuality > bQuality
end

function CoachTaskPlayerChooseModel:ctor(taskData, clickIndex, selectMap, taskCardInfo)
    self.super.ctor(self)
    self.data = taskData
    self.clickIndex = clickIndex
    self.selectMap = selectMap
    self.taskCardInfo = taskCardInfo
    self:InitData()
end

function CoachTaskPlayerChooseModel:GetTaskList()
    return self.data.alist
end

function CoachTaskPlayerChooseModel:GetExecutingTaskList()
    return self.data.dlist
end

function CoachTaskPlayerChooseModel:GetTaskChooseIndex()
    return self.clickIndex
end

function CoachTaskPlayerChooseModel:InitData()
    self.cardsMapModel = PlayerCardsMapModel.new()
    self.condition = {}
    -- 根据条件id读表  将所有条件组合为一个table
        -- {
        --     ["skill"] = 
        --         {
        --             {"C01" = "C01", "C02" = "C02"},
        --             {"A01" = "A01", "A02" = "A02"},
        --         },
        --     ["power"] = 
        --         {
        --             {"3000" = "3000"},
        --             {"5000" = "5000"},
        --         },
        -- }
    for i,v in ipairs(self.data.cond) do
        local index = tostring(v)
        local taskDetail = CoachMissionDetail[index]
        local missionCondition = taskDetail.missionCondition
        local missionCondition2 = taskDetail.missionCondition2
        if not self.condition[missionCondition] then
            self.condition[missionCondition] = {}
        end
        table.insert(self.condition[missionCondition], missionCondition2)
    end
end

-- 筛选球员
function CoachTaskPlayerChooseModel:FilterPlayerCardModel()
    local cardList = self.cardsMapModel:GetCardList()
    local cardModelList = {}
    for i, pcid in ipairs(cardList) do
        local cardModel = PlayerCardModel.new(pcid)
        cardModel:InitEquipsAndSkills()
        if self:IsAvailable(cardModel) then
            local isMatchTask = true
            for k, conditionTable in pairs(self.condition) do
                if CoachTaskHelper.Condition[k] then
                    -- 根据 CoachTaskHelper.Condition 的名字对应的 function 来筛选
                    local funcName = "Check" .. CoachTaskHelper.Condition[k]
                    for index, conditionValue in ipairs(conditionTable) do
                        isMatchTask = self[funcName](self, cardModel, conditionValue)
                        if not isMatchTask then break end
                    end
                    if not isMatchTask then break end
                end
            end
            if isMatchTask then
                table.insert(cardModelList, cardModel)
            end
        end
    end
    table.sort(cardModelList, StartOrderComp)
    return cardModelList
end

-- 国家需求nation
function CoachTaskPlayerChooseModel:CheckNation(cardModel, condition)
    local nation = cardModel:GetNation()

    if condition[nation] then
        return true
    end
    return false
end

-- 球员品质quality
function CoachTaskPlayerChooseModel:CheckQuality(cardModel, condition)
    local quality = tostring(cardModel:GetCardQuality())
    local qualitySpecial = cardModel:GetCardQualitySpecial()
    local cardFixQuality = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)

    if condition[cardFixQuality] then
        return true
    end
    return false
end

-- 位置需求position
function CoachTaskPlayerChooseModel:CheckPosition(cardModel, condition)
    local position = cardModel:GetPosition()
    
    for i,v in ipairs(position) do
        if condition[tostring(v)] then
            return true
        end
    end
    return false
end

-- upgrade进阶
function CoachTaskPlayerChooseModel:CheckUpgrade(cardModel, condition)
    local upgrade = tostring(cardModel:GetUpgrade())

    if condition[upgrade] then
        return true
    end
    return false
end

-- 技能强化（技能为自身技能 贴纸技能除外）skill
-- 技能必须为已解锁技能
function CoachTaskPlayerChooseModel:CheckSkill(cardModel, condition)
    -- 将技能转换为 key=技能id value=技能信息 减少循环
    local allSkills = cardModel:GetSkills()
    local allSkillKV = {}
    for i, v in ipairs(allSkills) do
        allSkillKV[v.sid] = v
    end

    local skill = cardModel:GetStaticSkills()
    for i,v in pairs(skill) do
        if allSkillKV[v].isOpen and condition[v] then
            return true
        end
    end
    return false
end

-- 战力需求Power
function CoachTaskPlayerChooseModel:CheckPower(cardModel, condition)
    local power = cardModel:GetPower()
    local conditionPower = next(condition)
    conditionPower = tonumber(conditionPower)
    
    return power >= conditionPower
end

-- 转生要求ascend
function CoachTaskPlayerChooseModel:CheckAscend(cardModel, condition)
    local ascend = tostring(cardModel:GetAscend())
    
    if condition[ascend] then
        return true
    end
    return false
end

-- 特训要求TrainingBase
function CoachTaskPlayerChooseModel:CheckTrainingBase(cardModel, condition)
    local allBase, trainingBase = cardModel:GetTrainingBase()
    trainingBase = tostring(trainingBase)
    
    if condition[trainingBase] then
        return true
    end
    return false
end

function CoachTaskPlayerChooseModel:IsAvailable(cardModel)
    local pcid = cardModel:GetPcid()
    local choosePcid = self:GetNowChoosePcid()

    if pcid == choosePcid then return true end

    for k,v in pairs(self.selectMap) do
        if pcid == v then
            return false
        end
    end

    for k,v in pairs(self.taskCardInfo) do
        if tostring(pcid) == tostring(v) then
            return false
        end
    end
    return true
end

-- 进入页面初始化 已选择的卡片
function CoachTaskPlayerChooseModel:GetNowChoosePcid()
    local chooseIndex = self:GetTaskChooseIndex()
    local choosePcid = self.selectMap[chooseIndex]
    return choosePcid
end

function CoachTaskPlayerChooseModel:GetSelectIndex(cardModelList)
    local pcid = self:GetNowChoosePcid()
    if not pcid then return end
    for i,v in ipairs(cardModelList) do
        local tPcid = v:GetPcid()
        if pcid == tPcid then
            return i
        end
    end
end

return CoachTaskPlayerChooseModel
