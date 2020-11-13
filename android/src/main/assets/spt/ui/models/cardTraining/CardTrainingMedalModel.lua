local PlayerCorrelation = require("data.PlayerCorrelation")
local TrainingComplete = require("data.TrainingComplete")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local Medal = require("data.Medal")
local Model = require("ui.models.Model")

local CardTrainingMedalModel = class(Model, "CardTrainingMedalModel")

function CardTrainingMedalModel:ctor(cid)
    self.staticData = {}
    self.cid = cid
    self.cardData = PlayerCorrelation[self.cid]
end

function CardTrainingMedalModel:InitWithProtocol(matchId, medalData)
    self.matchId = matchId
    self.medalData = medalData
    self.trainData = TrainingComplete[self.matchId]
end

function CardTrainingMedalModel:GetNeedQuality()
    return self.trainData.medalQuality
end

function CardTrainingMedalModel:GetNeedBoxQuality()
    return self.trainData.medalQuality
end

function CardTrainingMedalModel:GetMedalContent()
    if self.medalData and type(self.medalData) == "table" and next(self.medalData) then
        local medalId, num = next(self.medalData)
        return {{id = medalId, num = num}}
    end
    return {defualt = true} 
end

function CardTrainingMedalModel:IsCanUse()
    return next(self:GetMedalList()) and #self:GetMedalList()
end

function CardTrainingMedalModel:GetMedalList()
    self.playerMedalsMapModel = self.playerMedalsMapModel or PlayerMedalsMapModel.new()
    local medalsMap = self.playerMedalsMapModel:GetMedalMap()
    self.medalsModelList = {}
    local medalBase = self:GetBaseAttr()
    for pmid,v in pairs(medalsMap) do
        local baseAttr = next(v.baseAttribute)
        local exAttrName = v.extraAttribute and next(v.extraAttribute)
        local isCanUse = medalBase[baseAttr] and tonumber(Medal[tostring(v.medalId)].quality) >= tonumber(self.trainData.medalQuality)
        isCanUse = isCanUse and medalBase[exAttrName] and self:IsInExAttr(v.extraAttribute and v.extraAttribute[exAttrName])
        isCanUse = isCanUse and self:IsHaveSkill(v.skill)
        isCanUse = isCanUse and v.pcid == nil
        if isCanUse then
            local playerMedalModel = PlayerMedalModel.new(v.pmid)
            playerMedalModel:InitWithCache(v)
            table.insert(self.medalsModelList, playerMedalModel)
        end
    end
    return self.medalsModelList
end

function CardTrainingMedalModel:ResetMedalList()
    self.medalsModelList = nil
end

function CardTrainingMedalModel:GetInfoData()
    local infoData = {}
    infoData.base = self.cardData.medalBase
    infoData.extra = {min = tonumber(self.trainData.medalRange)}
    infoData.skill = {}
    local range, lvlLimit = next(self.trainData.medalSkill)
    for i=1, tonumber(range) do
        if self.cardData.medalAdditionalSkill[i] then
            table.insert(infoData.skill, {skillName = self.cardData.medalAdditionalSkill[i], lvl = lvlLimit})
        end
    end
    return infoData
end

function CardTrainingMedalModel:GetBaseAttr()
    local medalBase = {}
    for k,v in pairs(self.cardData.medalBase) do
        medalBase[v] = true
    end
    return medalBase
end

function CardTrainingMedalModel:IsInExAttr(num)
    if not num then return false end
    if tonumber(num) < tonumber(self.trainData.medalRange) * 0.001 then
        return false
    end
    return true
end

function CardTrainingMedalModel:IsHaveSkill(skillData)
    if not skillData or not next(skillData) then return false end
    local range, lvlLimit = next(self.trainData.medalSkill)
    local skillNane, lvl = next(skillData)
    if lvl < tonumber(lvlLimit) then
        return false
    end
    local flag = false
    for i=1, tonumber(range) do
        if self.cardData.medalAdditionalSkill[i] and self.cardData.medalAdditionalSkill[i] == skillNane then
            flag = true
            break
        end
    end
    return flag
end

return CardTrainingMedalModel