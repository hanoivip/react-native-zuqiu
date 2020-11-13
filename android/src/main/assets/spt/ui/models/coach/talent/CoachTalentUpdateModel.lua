local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local CoachTalentUpdateModel = class(Model, "CoachTalentUpdateModel")

function CoachTalentUpdateModel:ctor()
    self.data = nil
    self.coachTalentModel = nil
end

function CoachTalentUpdateModel:InitWithParent(cacheData, parentModel)
    self.data = cacheData
    self.coachTalentModel = parentModel
    self.playerInfoModel = PlayerInfoModel.new()
end

function CoachTalentUpdateModel:GetData()
    return self.data
end

function CoachTalentUpdateModel:GetStatusData()
    return self
end

-- 获得教练天赋点数目
function CoachTalentUpdateModel:GetCtp()
    return self.playerInfoModel:GetCoachTalentPoint()
end

-- 获得欧元数目
function CoachTalentUpdateModel:GetMoney()
    return self.playerInfoModel:GetMoney()
end

-- 解锁后更新数据
function CoachTalentUpdateModel:UpdateAfterUnlock(skillData, talent, cost)
    if self.coachTalentModel then
        self.coachTalentModel:UpdateAfterUnlock(skillData, talent, cost)
    end
end

-- 升级后更新数据
function CoachTalentUpdateModel:UpdateAfterUpgrade(skillData, talent, cost)
    if self.coachTalentModel then
        self.coachTalentModel:UpdateAfterUpgrade(skillData, talent, cost)
    end
end

return CoachTalentUpdateModel
