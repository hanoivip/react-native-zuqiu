local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")

local AssistantCoachUpdateModel = class(Model, "AssistantCoachUpdateModel")

function AssistantCoachUpdateModel:ctor()
    self.acModel = nil
    self.parentModel = nil
    self.playerInfoModel = nil
    self.coachMainModel = CoachMainModel.new()
end

function AssistantCoachUpdateModel:InitWithParent(assistantCoachModel, parentModel)
    self.acModel = assistantCoachModel
    self.parentModel = parentModel
    self.playerInfoModel = PlayerInfoModel.new()
end

function AssistantCoachUpdateModel:GetStatusData()
    return self
end

function AssistantCoachUpdateModel:GetAssistantCoachModel()
    return self.acModel
end

-- 获得助理教练id
function AssistantCoachUpdateModel:GetAcid()
    return self.acModel:GetId()
end

-- 获得助理教练名字
function AssistantCoachUpdateModel:GetName()
    return self.acModel:GetName()
end

-- 获取用户当前拥有的助理教练经验书数量
function AssistantCoachUpdateModel:GetCurrAce()
    return self.playerInfoModel:GetAssistantCoachExp()
end

-- 获得升级所需经验书数量
function AssistantCoachUpdateModel:GetNeedAceNum()
    return self.acModel:GetUpdateAce()
end

-- 升级后更新
function AssistantCoachUpdateModel:UpdateAfterUpgrade(data)
    self.acModel:Upgrade(data)
    if data.cost ~= nil and tostring(data.cost.type) == CurrencyType.AssistantCoachExp then
        self.playerInfoModel:SetAssistantCoachExp(data.cost.curr_num)
    end
    if self.acModel:IsInTeam() then
        self.coachMainModel:RefreshAssistantData(self.acModel:GetTeamIdx(), self.acModel:GetCacheData())
    end
end

return AssistantCoachUpdateModel
