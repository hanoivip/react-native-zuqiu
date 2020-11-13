local CoachMainModel = require("ui.models.coach.CoachMainModel")

local OtherCoachMainModel = class(CoachMainModel, "OtherCoachMainModel")

function OtherCoachMainModel:ctor(otherTeamsModel)
    OtherCoachMainModel.super.ctor(self, nil, otherTeamsModel)
end

function OtherCoachMainModel:Init(data)
    if not data then
        data = cache.getOtherCoachInfo()
    end
    self.cacheData = data or {}
end

function OtherCoachMainModel:InitWithProtocol(cacheData, isCacheMission)
    cache.setOtherCoachInfo(cacheData)
    self.cacheData = cacheData or {}
    self:CacheCoachAttrs()
end

function OtherCoachMainModel:CacheCoachAttrs()
    self:CacheAssistantPower()
end

function OtherCoachMainModel:CacheAssistantPower()
    local assistantAttr, assistantSkillLvl = self:CacheAssistantPowerCore(self:GetAssistantData())
    cache.setOtherCoachAssistantAttr(assistantAttr)
    cache.setOtherCoachAssistantSkillLvl(assistantSkillLvl)
end

-- 助理教练带来的属性加成
function OtherCoachMainModel:GetAssistantAttr()
    return cache.getOtherCoachAssistantAttr()
end

-- 助理教练带来的技能加成
function OtherCoachMainModel:GetAssistantSkillLvl()
    return cache.getOtherCoachAssistantSkillLvl()
end

function OtherCoachMainModel:SetPlayerCardModel(playerCardModel)
    self.playerCardModel = playerCardModel
end

return OtherCoachMainModel
