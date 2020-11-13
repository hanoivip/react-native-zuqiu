local Model = require("ui.models.Model")
local CoachMainModel = require("ui.models.coach.CoachMainModel")

local CoachMainPageModel = class(Model, "CoachMainPageModel")

function CoachMainPageModel:ctor()
    self.coachMainModel = CoachMainModel.new()
end

function CoachMainPageModel:InitWithProtocol(cacheData)
    self.cacheData = cacheData
    self.coachMainModel:InitWithProtocol(cacheData.coach)
end

function CoachMainPageModel:GetData()
    return self.cacheData
end

function CoachMainPageModel:GetCredentialLevel()
    return self.coachMainModel:GetCredentialLevel()
end

function CoachMainPageModel:GetStarLevel()
    return self.coachMainModel:GetStarLevel()
end

-- 获得基本信息界面所需数据
function CoachMainPageModel:GetBaseInfo()
    return self.cacheData
end

-- 获得执教天赋界面所需数据
function CoachMainPageModel:GetTalentData()
    return self.cacheData.coach.talent or {}
end

-- 获得助理教练团队页面所需数据
function CoachMainPageModel:GetAssistantCoachData()
    return self.cacheData
end

-- 获得重置教练天赋点所需钻石
function CoachMainPageModel:GetResetTalentPointCost()
    return self.cacheData.coachTalentResetPrice or 0
end

return CoachMainPageModel
