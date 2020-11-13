local Medal = require("data.Medal")
local Skills = require("data.Skills")
local Model = require("ui.models.Model")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local Card = require("data.Card")

local PlayerMedalModel = class(Model, "PlayerMedalModel")

function PlayerMedalModel:ctor(pmid)
    self.pmid = pmid
    self.data = {}
    self.static = {}

    self.playerCardsMapModel = PlayerCardsMapModel.new()
end

function PlayerMedalModel:InitWithCache(data)
    self.data = data
    self.pmid = data.pmid 
    self:InitWithStatic(data.medalId)
end

function PlayerMedalModel:InitWithStatic(medalId)
    self.medalId = medalId
    self.static = Medal[tostring(medalId)]
end

function PlayerMedalModel:GetMedalData()
    return self.data
end

function PlayerMedalModel:GetMedalId()
    return self.medalId
end

function PlayerMedalModel:GetPmid()
    return self.pmid
end

function PlayerMedalModel:GetPos()
    return self.data.position
end

function PlayerMedalModel:GetAddNum()
    return self.data.add
end

function PlayerMedalModel:GetBaseAttr()
    return self.data.baseAttribute or {}
end

function PlayerMedalModel:GetAttrPlus(abilityIndex)
    local baseAttribute = self:GetBaseAttr()
    return baseAttribute[tostring(abilityIndex)]
end

function PlayerMedalModel:GetExAttr()
    return self.data.extraAttribute or {}
end

function PlayerMedalModel:GetBenediction()
    return self.data.bless or {}
end

function PlayerMedalModel:GetBenedictionNameAndLvl()
    local bless = self:GetBenediction()
    local name, lvl, benedictionSid = "", "", nil
    for sid, plus in pairs(bless) do
        local medalSkill = Skills[tostring(sid)]
        name = medalSkill.skillName
        lvl = plus
        benedictionSid = sid
    end
    return name, lvl, benedictionSid
end

function PlayerMedalModel:GetSkillNameAndLvl()
    local skill = self:GetSkill()
    local name, lvl, skillSid = "", "", nil
    for sid, plus in pairs(skill) do
        local medalSkill = Skills[tostring(sid)]
        name = medalSkill.skillName
        lvl = plus
        skillSid = sid
    end
    return name, lvl, skillSid
end

function PlayerMedalModel:GetSkill()
    return self.data.skill or {}
end

-- 默认表分配数据
function PlayerMedalModel:GetStatic()
    return self.static
end

function PlayerMedalModel:GetName()
    return self.static.name
end

function PlayerMedalModel:GetPic()
    local picIndex = ""
    if self:HasBroken() then 
        picIndex = self:GetBrokenPic()
    else
        picIndex = self.static.picIndex
    end
    return picIndex
end

function PlayerMedalModel:GetBrokenPic()
    return self.static.brokenPic
end

function PlayerMedalModel:GetBroken()
    return self.data.broken
end

function PlayerMedalModel:HasEquiped()
    return tobool(self.data.pcid ~= nil)
end

function PlayerMedalModel:GetCarrierPcid()
    return self.data.pcid or ""
end

function PlayerMedalModel:GetCarrierCid()
    local cardCacheData = self.playerCardsMapModel:GetCardData(self:GetCarrierPcid())
    return cardCacheData ~= nil and cardCacheData.cid or nil
end

function PlayerMedalModel:HasBroken()
    return tobool(tonumber(self.data.broken) == 1)
end

function PlayerMedalModel:IsNew()
    return self.data.isNew or false
end

function PlayerMedalModel:SetNew(isNew)
    self.data.isNew = isNew
end

function PlayerMedalModel:GetBenedictionState()
    local state = self.static.BlessMark or 0
    return state
end

function PlayerMedalModel:GetQuality()
    return self.static.quality
end

function PlayerMedalModel:GetBoxQuality()
    return self.static.boxQuality
end

function PlayerMedalModel:GetMedalAdvanced()
    return self.static.medalAdvanced
end

function PlayerMedalModel:GetMedalType()
    return self.static.medalType
end

function PlayerMedalModel:GetStaticAttr()
    return self.static.medalBaseType or {}
end

function PlayerMedalModel:GetExAttrMinPercent()
    return self.static.additionalAttributeTopLimit / 1000
end

function PlayerMedalModel:GetExAttrMaxPercent()
    return self.static.additionalAttributeDownLimit / 1000 
end

function PlayerMedalModel:GetBreakTroughMinPercent()
    return self.static.medalBreakThroughDownLimit / 1000
end

function PlayerMedalModel:GetBreakTroughMaxPercent()
    return self.static.medalBreakThroughTopLimit / 1000 
end

function PlayerMedalModel:GetRandomSkill()
    return self.static.additionalSkillLevelUp
end

function PlayerMedalModel:GetRandomBenediction()
    return self.static.blessSkillLevel
end

function PlayerMedalModel:IsCanUpGrade()
    local condition = self.static.medalAdvancedAdditionalAttributeCondition
    if not condition or condition == 0 then
        return true
    end
    local exAttr = self:GetExAttr()
    if next(exAttr) then
        local name, plus = next(exAttr)
        return plus and plus * 1000 >= condition or false, condition
    else
        return false, condition
    end
end

function PlayerMedalModel:GetAdvancedConsume()
    return self.static.medalAdvancedConsume
end

function PlayerMedalModel:GetAdvancedProtect()
    return self.static.medalAdvancedProtect and self.static.medalAdvancedProtect ~= '' and self.static.medalAdvancedProtect or {}
end

function PlayerMedalModel:GetBenedictionConsume()
    return self.static.medalbelssAdvamcedConsume or 0
end

function PlayerMedalModel:GetBenedictionReplaceConsume()
    return self.static.medalbelssChangeConsume or 0
end

function PlayerMedalModel:GetAttributeBreakConsume()
    return self.static.medalBreakThroughPrice or 0
end

function PlayerMedalModel:GetMedalBlessAdvanced()
    return self.static.medalBlessAdvanced
end

function PlayerMedalModel:GetMedalState()
    return self.static.medalState
end

function PlayerMedalModel:GetMedalTypeName()
    return self.static.medalQualityName
end

function PlayerMedalModel:GetMedalStardust()
    return self.static.decompositionBase
end

function PlayerMedalModel:GetState(key)
    local isOpen = false
    if self:HasBroken() then 
        return isOpen
    end
    local state = self:GetMedalState()
    for i, v in ipairs(state) do
        if(tonumber(v) == key) then 
            isOpen = true
            break
        end
    end
    return isOpen
end

return PlayerMedalModel
