local TrainingUnlock = require("data.TrainingUnlock")
local PlayerCorrelation = require("data.PlayerCorrelation")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local TrainingEffect = require("data.TrainingEffect")
local PlayerType = require("data.PlayerType")
local TrainingComplete = require("data.TrainingComplete")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CardTrainingConstant = require("ui.scene.cardTraining.CardTrainingConstant")
local CardTrainingMedalMode = require("ui.models.cardTraining.CardTrainingMedalModel")
local Card = require("data.Card")
local Skills = require("data.Skills")
local Model = require("ui.models.Model")

local CardTrainingMainModel = class(Model, "CardTrainingMainModel")

function CardTrainingMainModel:ctor(cardDetailModel)
    CardTrainingMainModel.super.ctor(self)
    self.cardDetailModel = cardDetailModel
    self.cardModel = cardDetailModel:GetCardModel()
end

function CardTrainingMainModel:InitWithProtocol(data)
    self.data = data
    local isTrainingUseSelf = self.cardModel:IsTrainingUseSelf()
    if not isTrainingUseSelf then
        self.data.training = self.data.trainingSupporter
    end
    for k,v in pairs(self.data.training) do
        if type(v) == "table" then
            local condition = {}
            local correlationCondition = {}
            if v.condition.correlationCard1Condition then 
                correlationCondition.correlationCard1Condition = v.condition.correlationCard1Condition
                v.condition.correlationCard1Condition = nil
            end
            if v.condition.correlationCard2Condition then 
                correlationCondition.correlationCard2Condition = v.condition.correlationCard2Condition
                v.condition.correlationCard2Condition = nil
            end
            if v.condition.correlationCondition then
                correlationCondition.correlationCondition = v.condition.correlationCondition
                v.condition.correlationCondition = nil
            end
            
            for key,value in pairs(v.condition) do
                condition[key] = value
            end
            if next(correlationCondition) then
                condition.correlationCondition = correlationCondition
            end
            v.condition = condition
        end
    end
    self.currTag = self.currTag or (self.data.training.trainId and  tostring(self.data.training.trainId)) or "1"
    self:InitTrainingInfo()
end

function CardTrainingMainModel:InitTrainingInfo()
    self.trainingBaseInfo = {}
    for k, v in pairs(TrainingUnlock) do
        v.sortOrder = k
        table.insert(self.trainingBaseInfo, v)
    end
    table.sort(self.trainingBaseInfo, function (a, b)
        return tonumber(a.sortOrder) < tonumber(b.sortOrder)
    end)
end

function CardTrainingMainModel:GetMenuScrollPos()
    return self.currScrollPos
end

function CardTrainingMainModel:SetMenuScrollPos(scrollPos)
    self.currScrollPos = scrollPos
end

function CardTrainingMainModel:GetOpenTrainingLevelInfo()
    local openLevelInfo = {}
    local quality = self.cardDetailModel:GetCardModel():GetCardQuality()
    for i, v in ipairs(self.trainingBaseInfo) do
        for k, openLevel in pairs(v.unlockQuality) do
            if tonumber(quality) == tonumber(openLevel) then
                table.insert(openLevelInfo, v)
            end
        end
    end

    -- 加入是否开启的字段和进行到第几小关的字段
    for k, v in pairs(openLevelInfo) do
        v.lock = not self.data.training[tostring(k)].open
        v.subId = self.data.training[tostring(k)].subId
    end

    return openLevelInfo
end

function CardTrainingMainModel:GetIsLockByLevel(lvl)
    local info = self:GetOpenTrainingLevelInfo()
    return info[tonumber(lvl)] and info[tonumber(lvl)].lock
end

function CardTrainingMainModel:GetIsFinishByLevel(tag)
    -- subId == 6时代表前5小关均已完成
    return self.data.training[tostring(tag)] and self.data.training[tostring(tag)].subId == 6
end

-- 获得当前关卡的进行到了第几小关卡
function CardTrainingMainModel:GetSubIdByLevel(tag)
    return self.data.training[tostring(tag)] and self.data.training[tostring(tag)].subId
end

function CardTrainingMainModel:GetCurrLevelSelected()
    -- 因为第一个标签的id为1
    return self.currTag or "1"
end

function CardTrainingMainModel:SetCurrLevelSelected(level)
    self.currTag = level
end

function CardTrainingMainModel:GetConditionInfoByTag(tag)
    return self.data.training[tostring(tag)] and self.data.training[tostring(tag)].condition
end

function CardTrainingMainModel:GetName()
    local lvl = self:GetCurrLevelSelected()
    return self:GetNameByLevel(lvl)
end

function CardTrainingMainModel:GetNameByLevel(lvl)
    return TrainingUnlock[tostring(lvl)].name
end

function CardTrainingMainModel:GetLockPageCorrelationName()
    local cid = self.cardDetailModel:GetCardModel():GetCid()
    local cid1, cid2 = PlayerCorrelation[cid].correlationPlayer1, PlayerCorrelation[cid].correlationPlayer2

    if cid1 and cid2 then
        local cardModel = StaticCardModel.new(cid1)
        local name1 = cardModel:GetName()
        cardModel = StaticCardModel.new(cid2)
        local name2 = cardModel:GetName()
        name1 = string.convertNoToQuality(string.sub(cid1, -1)) .. name1
        name2 = string.convertNoToQuality(string.sub(cid2, -1)) .. name2
        return name1, name2
    else
        return nil, nil
    end
end

-- return type:table, table
function CardTrainingMainModel:GetAttributePlusByLevel(lvl)
    local subId = self.data.training[tostring(lvl)] and self.data.training[tostring(lvl)].subId
    if not subId then
        return nil
    end

    local effectInfo = TrainingEffect[tostring(lvl) .. "0" .. tostring(subId)]
    local attributeName = {}

    -- 1代表全系加成
    if effectInfo.attributeImproveType == CardTrainingConstant.ImproveStyle.AllImprove then
        local isGK = self.cardModel:IsGKPlayer()
        if isGK then
            for k, v in pairs(CardHelper.GoalKeeperOrder) do
                table.insert(attributeName, lang.transstr(v))
            end
        else
            for k, v in pairs(CardHelper.NormalPlayerOrder) do
                table.insert(attributeName, lang.transstr(v))
            end
        end
    -- 2代表部分加成
    elseif effectInfo.attributeImproveType == CardTrainingConstant.ImproveStyle.PartImprote then
        local baseAttribute = PlayerCorrelation[self.cardModel:GetCid()].baseAttribute
        local playerType = PlayerType[tostring(baseAttribute)].playerType
        for k, v in pairs(playerType) do
            table.insert(attributeName, lang.transstr(v))
        end
    end
    return attributeName, effectInfo.attributeImprove
end

local NumToYY = {"firstSkillEx", "secondSkillEx", "thirdSkillEx", "fourthSkillEx", "fifthSkillEx"}
function CardTrainingMainModel:GetSkillDescData(lvl)
    local subId = self.data.training[tostring(lvl)] and self.data.training[tostring(lvl)].subId
    if not subId then
        return nil
    end
    local effectInfo = TrainingEffect[tostring(lvl) .. "0" .. tostring(subId)]
    local result = ""
    local isSingle = 0
    if effectInfo.choicePlate == 1 then
        local allSkill = ""
        for skillId, addLvl in pairs(effectInfo.skillLvImprove) do
            if tonumber(skillId) == 0 then
                allSkill = lang.transstr("card_training_rule_allSkill") .. "Lv+" .. addLvl .. " / "
                isSingle = isSingle + 1
            else
                local tempCardData = Card[self:GetCid()].skill[tonumber(skillId)]
                if tempCardData then
                    result = result .. Skills[tempCardData].skillName .. "Lv+" .. addLvl .. " / "
                    isSingle = isSingle + 1
                end
            end
        end
        result = allSkill .. result
        return (isSingle > 1) and lang.transstr("card_training_rule_task_skillAdd", string.sub(result, 1, #result - 2)) or string.sub(result, 1, #result - 2)
    end

    if effectInfo.choicePlate == 2 then
        local skillData = Skills[PlayerCorrelation[self:GetCid()][NumToYY[effectInfo.skillImprove]][1]]
        return tonumber(skillData.openValue) == 1 and lang.transstr("card_training_rule_task_skillUp", skillData.skillName) or lang.transstr("commingSoon")
    end
end

function CardTrainingMainModel:GetFinishAttribute()
    local lvl = self:GetCurrLevelSelected()
    local effect = self.data.training[tostring(lvl)] and self.data.training[tostring(lvl)].effect
    return effect
end

-- 冷却时间
function CardTrainingMainModel:GetColdDownHour()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    return TrainingComplete[lvl .. "0" .. subId].coolDown
end

function CardTrainingMainModel:GetCurrLvlCoolTime()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    return self.data.training[tostring(lvl)][tostring(subId)] and self.data.training[tostring(lvl)][tostring(subId)].coolRemainTime
end

function CardTrainingMainModel:SetCurrLvlCoolTime(lvl, subId, time)
    self.data.training[tostring(lvl)][tostring(subId)].coolRemainTime = time
    EventSystem.SendEvent("CardTraining_RefreshCoolTime", lvl, subId, time)
end

function CardTrainingMainModel:GetCoolDownPrice()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    return TrainingComplete[lvl .. "0" .. subId].coolDownPrice
end

-- 6级代表均已完成，则返回完成之后的2个界面编号
function CardTrainingMainModel:GetLetterContentTypeByLevel(lvl)
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    local plate = TrainingComplete[tostring(lvl) .. "0" .. tostring(subId)] and tonumber(TrainingComplete[tostring(lvl) .. "0" .. tostring(subId)].upgradePlate)
    if plate then
        return plate
    else
        plate = TrainingEffect[tostring(lvl) .. "0" .. CardTrainingConstant.MaxSubId].choicePlate
        if tonumber(plate) == 1 then
            return CardTrainingConstant.LetterPart.FinishOnlyAttribute
        elseif tonumber(plate) == 2 then
            return CardTrainingConstant.LetterPart.FinishWithSkill
        else
            assert(nil, "Excel has proplem!!!")
        end
    end
end

function CardTrainingMainModel:GetOption()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    return TrainingEffect[tostring(lvl) .. "0" .. CardTrainingConstant.MaxSubId].choicePlate
end

function CardTrainingMainModel:GetExp()
    return self:GetExpByLevel()
end

function CardTrainingMainModel:GetExpByLevel(lvl)
    lvl = lvl or self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    return self.data.training[tostring(lvl)][tostring(subId)] and self.data.training[tostring(lvl)][tostring(subId)].exp or 0
end

function CardTrainingMainModel:SetExp(exp)
    self:SetExpByLevel(nil, exp)
end

function CardTrainingMainModel:SetExpByLevel(lvl, exp)
    lvl = lvl or self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    if not self.data.training[tostring(lvl)] then
        self.data.training[tostring(lvl)] = {}
    end
    if not self.data.training[tostring(lvl)][tostring(subId)] then
        self.data.training[tostring(lvl)][tostring(subId)] = {}
    end
    self.data.training[tostring(lvl)][tostring(subId)].exp = exp
end

-- 完成任务需要多少经验
function CardTrainingMainModel:GetNeedExp()
    return self:GetNeedExpByLevel()
end

function CardTrainingMainModel:GetNeedExpByLevel(lvl)
    lvl = lvl or self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    return TrainingComplete[tostring(lvl) .. "0" .. tostring(subId)].experience
end

function CardTrainingMainModel:GetPcid()
    return self.cardModel:GetPcid()
end

function CardTrainingMainModel:GetCid()
    return self.cardModel:GetCid()
end

-- 获得当前关卡需要的装备 key = 装备id，value=需要的数量
function CardTrainingMainModel:GetEquipInfo()
    local plate = self:GetLetterContentTypeByLevel(self:GetCurrLevelSelected())
    local cid = self:GetCid()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    local equipQuality = TrainingComplete[tostring(lvl) .. "0" .. tostring(subId)].equipQuality
    local equip = TrainingComplete[tostring(lvl) .. "0" .. tostring(subId)].contents.eqs
    if not equip then return end

    local equipBase = PlayerCorrelation[cid].equipBase
    assert(equipBase, "Excel has proplem")

    local equipIdMap = {}
    for k, v in pairs(equip) do
        -- 低级卡牌可能没有这个位置的装备
        if equipBase[tonumber(v.id)] then
            local equipId = equipQuality .. equipBase[tonumber(v.id)]
            local equipNum = equipIdMap[equipId] or 0
            equipIdMap[equipId] = equipNum + v.num
        end
    end

    return equipIdMap
end

-- 获得当前关卡需要的道具信息
function CardTrainingMainModel:GetNeedItemInfo()
    local plate = self:GetLetterContentTypeByLevel(self:GetCurrLevelSelected())
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    self:PushMedalInfo(self.data.training[tostring(lvl)], tostring(subId))
    return self.data.training[tostring(lvl)] and self.data.training[tostring(lvl)][tostring(subId)].contents
end

function CardTrainingMainModel:PushMedalInfo(challengeData, subId)
    if not challengeData then
        return
    end
    if TrainingComplete[self:GetChallengeID()].medalQuality or TrainingComplete[self:GetChallengeID()].medalRange or TrainingComplete[self:GetChallengeID()].medalSkill then
        if not self.cardTrainingMedalMode then
            self.cardTrainingMedalMode = CardTrainingMedalMode.new(self:GetCid())
        end
        self.cardTrainingMedalMode:InitWithProtocol(self:GetChallengeID(), challengeData[subId].medal)
        challengeData[subId].contents.medal = self.cardTrainingMedalMode:GetMedalContent()
    end
end

function CardTrainingMainModel:GetCardTrainingMedalMode()
    return self.cardTrainingMedalMode
end

function CardTrainingMainModel:GetChallengeID()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    return tostring(lvl) .. "0" .. tostring(subId)
end

-- 根据装备的索引获得装备的id
function CardTrainingMainModel:GetEquipIdByIndex(index)

end

-- 由于卡牌消耗一张即可，检查服务器传过来的字段是否为1
function CardTrainingMainModel:GetIsFinishCardConsume()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    return self.data.training[tostring(lvl)] and tonumber(self.data.training[tostring(lvl)][tostring(subId)].card) == 1
end

function CardTrainingMainModel:GetNeedItemMaxCountByTypeAndId(itemType, id)
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    local data = TrainingComplete[tostring(lvl) .. "0" .. tostring(subId)].contents
    assert(data, "Excel has proplem!")
    if id then
        if itemType == "eqs" then
            local equipInfo = self:GetEquipInfo()
            for k, v in pairs(equipInfo) do
                if tonumber(id) == tonumber(k) then
                    return tonumber(v)
                end
            end
        end
        for k, v in pairs(data[itemType]) do
            if tonumber(id) == tonumber(v.id) then
                return tonumber(v.num)
            end
        end
    -- 欧元等不是table的格式
    else
        if itemType == "medal" then
            return 1 
        end
        return tonumber(data[itemType])
    end
end

-- 右侧完成之后的技能信息
function CardTrainingMainModel:GetExSkillInfo()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    local subInfo = self.data.training[tostring(lvl)][tostring(CardTrainingConstant.MaxSubId)]
    if not subInfo then return end
    local exSkill = subInfo.effect and subInfo.effect.exSkill
    if exSkill then
        for k, v in pairs(exSkill) do
            local isOpen = Skills[k] and tonumber(Skills[k].openValue) == 1
            return k, v, isOpen
        end
    end
end

-- 当五小关均完成以后，option=1时的技能等级属性增加
function CardTrainingMainModel:GetSkillAttributeArray()
    local skills = {}
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    local skillLvImprove = TrainingEffect[lvl .. "0" .. CardTrainingConstant.MaxSubId].skillLvImprove
    local skillList = self.cardModel:GetSkills()
    -- 排序
    local tempSkillLvImprove = {}
    for k, v in pairs(skillLvImprove) do
        local tempSkill = {}
        tempSkill.id = tonumber(k)
        tempSkill.attributePlus = v
        table.insert(tempSkillLvImprove, tempSkill)
    end
    table.sort(tempSkillLvImprove, function (a, b)
        return tonumber(a.id) < tonumber(b.id)
    end)
    
    for k, v in pairs(tempSkillLvImprove) do
        -- 全技能等级添加
        if v.id == 0 then
            table.insert(skills, {name = CardTrainingConstant.AllSkillLvlImprove, attributePlus = v.attributePlus, option = v.id})
        end
        -- 只添加球员本身的技能  贴纸技能排除
        if skillList[v.id] and (not skillList[v.id].ptid) then
            table.insert(skills, {name = skillList[v.id].sid, attributePlus = v.attributePlus, option = v.id})
        end
    end

    return skills
end

-- 当五小关均完成以后，option=2时的技能
function CardTrainingMainModel:GetSkillArray()
    local lvl = self:GetCurrLevelSelected()
    local subId = self:GetSubIdByLevel(lvl)
    local skillImprove = TrainingEffect[lvl .. "0" .. CardTrainingConstant.MaxSubId].skillImprove
    local skillEx = PlayerCorrelation[self:GetCid()][CardTrainingConstant.SkillImproveMap[skillImprove]]
    assert(skillEx, "Excel has proplem!!!")
    return skillEx
end

function CardTrainingMainModel:GetMaxSubLevelRewardContent()
    local lvl = self:GetCurrLevelSelected()
    return self.data.training[tostring(lvl)][tostring(CardTrainingConstant.MaxSubId)].effect.skills
end

function CardTrainingMainModel:GetLvlImproveOfSkillSelectedOption()
    local lvl = self:GetCurrLevelSelected()
    return self.data.training[tostring(lvl)][tostring(CardTrainingConstant.MaxSubId)].skillOption
end

function CardTrainingMainModel:GetMaxSubLevelRewardExSkills()
    local lvl = self:GetCurrLevelSelected()
    return self.data.training[tostring(lvl)][tostring(CardTrainingConstant.MaxSubId)].effect.exSkill
end

local AnimCondition = {PerId = 5, CurId = 6}
function CardTrainingMainModel:GetPlayFinishStatusFlag(oldLvl, oldSubId)
    if not oldLvl or not oldSubId then
        return false
    end
    if tonumber(oldSubId) ~= AnimCondition.PerId then
        return false
    end
    local currLvl = self:GetCurrLevelSelected()
    local currSubId = self:GetSubIdByLevel(currLvl)
    if tonumber(oldLvl) == tonumber(currLvl) and tonumber(currSubId) == AnimCondition.CurId then
        return true
    end
    return false
end

function CardTrainingMainModel:IsTrainingUseSelf()
    local isTrainingUseSelf = self.cardModel:IsTrainingUseSelf()
    return isTrainingUseSelf
end

function CardTrainingMainModel:GetCardModel()
    return self.cardModel
end

return CardTrainingMainModel

