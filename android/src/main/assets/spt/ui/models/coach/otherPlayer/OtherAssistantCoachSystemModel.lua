local CoachBaseLevel = require("data.CoachBaseLevel")
local AssistantCoachSystemModel = require("ui.models.coach.assistantSystem.AssistantCoachSystemModel")
local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")

local OtherAssistantCoachSystemModel = class(AssistantCoachSystemModel, "OtherAssistantCoachSystemModel")

function OtherAssistantCoachSystemModel:ctor()
    self.assistantCoachDatas = nil -- 助理教练信息
    self.assistantCoachModels = {} -- 助理教练model

    self.maxTeams = 0 -- 教练携带助理教练数目
    self.currMaxTeams = 0 -- 当前教练等级下可携带助理教练最大数
    self.currTeamIndex = nil

    self.teams = {} -- 助理团队的页签的数据
end

function OtherAssistantCoachSystemModel:InitWithProtocol(assistantCoach)
    self.assistantCoachDatas = assistantCoach
    self.mainCoach = mainCoach
    self.assistantCoachModels = {}

    self.maxTeams = table.nums(self.assistantCoachDatas)
    self.currMaxTeams = self.maxTeams
    self.currTeamIndex = 1

    self:ParseTeamsData()
    self:ParseAssistantCoachModels()
end

-- 解析数据从assistantCoachDatas生成assistantCoachModels
function OtherAssistantCoachSystemModel:ParseAssistantCoachModels()
    self.assistantCoachModels = {}
    for team = 1, self.maxTeams do
        local acData = self.assistantCoachDatas[tostring(team)]
        if acData then
            local acModel = AssistantCoachModel.new()
            acModel:InitWithProtocol(acData)
            acModel:SetTeamIdx(team)
            self.assistantCoachModels[tostring(team)] = acModel
        end
    end
end

function OtherAssistantCoachSystemModel:GetStatusData()
    return self.assistantCoachDatas
end

return OtherAssistantCoachSystemModel
