local PlayerCorrelation = require("data.PlayerCorrelation")
local TrainingComplete = require("data.TrainingComplete")
local TrainingEffect = require("data.TrainingEffect")
local TrainingUnlock = require("data.TrainingUnlock")
local Card = require("data.Card")
local Skills = require("data.Skills")
local PlayerType = require("data.PlayerType")
local Model = require("ui.models.Model")

local CardTrainingBaseRuleModel = class(Model, "CardTrainingBaseRuleModel")

function CardTrainingBaseRuleModel:ctor(cid)
    self.cid = cid
    self.cardData = PlayerCorrelation[self.cid]
end


function CardTrainingBaseRuleModel:GetItemDataList(key)
    if key == "train" then
        return self:GetTrainListData()
    end
    return {}
end

local CNum = 5
function CardTrainingBaseRuleModel:GetTrainListData()
    local trainData = {}
    local mIndex = 1
    local trainId = nil
    for k,v in pairs(TrainingUnlock) do
        if not self:IsUnLock(TrainingUnlock[tostring(mIndex)].unlockQuality) then
            break
        end
        local data = {}
        data.title = TrainingUnlock[tostring(mIndex)].name
        data.task = {}
        for subId = 1, CNum do
            local taskData = {}
            trainId = mIndex .. "0" .. subId
            taskData.num = subId
            self:GetTaskValue(trainId, taskData)
            table.insert(data.task, taskData)
        end
        table.insert(trainData, data)
        mIndex = mIndex + 1
    end
    return trainData
end

local ImproveType = {Single = 1, Mult = 2}
local NumToYY = {"firstSkillEx", "secondSkillEx", "thirdSkillEx", "fourthSkillEx", "fifthSkillEx"}
function CardTrainingBaseRuleModel:GetTaskValue(trainId, taskData)
    local result = ""
    if TrainingEffect[trainId].attributeImproveType == ImproveType.Single then
        taskData.value = lang.transstr("card_training_rule_allAttr", TrainingEffect[trainId].attributeImprove[1])
        return
    end
    if TrainingEffect[trainId].attributeImproveType == ImproveType.Mult then
        local vIndex = #PlayerType[tostring(PlayerCorrelation[self.cid].baseAttribute)].playerType
        for k, v in pairs(PlayerType[tostring(PlayerCorrelation[self.cid].baseAttribute)].playerType) do
            result = result .. lang.transstr(v) .. "+" .. TrainingEffect[trainId].attributeImprove[vIndex] .. "   "
        end
        taskData.value = result
        return
    end
    if not TrainingEffect[trainId].attributeImproveType then
        if TrainingEffect[trainId].skillImprove then
            local configSkills = PlayerCorrelation[self.cid][NumToYY[TrainingEffect[trainId].skillImprove]]
            taskData.skills = {}
            for k, sid in ipairs(configSkills) do
                local skillConfig = Skills[sid]
                local skill = {}
                skill.iconData = skillConfig.picIndex
                skill.value = tonumber(skillConfig.openValue) == 1 and lang.transstr("card_training_rule_task_skillDesc", skillConfig.desc) or lang.transstr("commingSoon")
                table.insert(taskData.skills, skill)
            end
            return
        end
        if TrainingEffect[trainId].skillLvImprove then
            local isSingle = 0
            local allSkill = ""
            for skillId, addLvl in pairs(TrainingEffect[trainId].skillLvImprove) do
                if tonumber(skillId) == 0 then
                    allSkill = lang.transstr("card_training_rule_allSkill") .. "Lv+" .. addLvl .. " / "
                    isSingle = isSingle + 1
                else
                    if Card[self.cid].skill[tonumber(skillId)] then
                        result = result .. Skills[Card[self.cid].skill[tonumber(skillId)]].skillName .. "Lv+" .. addLvl .. " / "
                        isSingle = isSingle + 1
                    end
                end
            end
            result = allSkill .. result
            taskData.value = (isSingle > 1) and lang.transstr("card_training_rule_task_skillAdd", string.sub(result, 1, #result - 2)) or string.sub(result, 1, #result - 2)
            return
        end
    end
end

function CardTrainingBaseRuleModel:IsUnLock(unlockQuality)
    for k,v in pairs(unlockQuality) do
        if tonumber(Card[self.cid].quality) == tonumber(v) then
            return true
        end
    end
    return false
end

return CardTrainingBaseRuleModel

