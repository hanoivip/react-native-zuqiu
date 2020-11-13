local Model = require("ui.models.Model")
local CoachBaseLevel = require("data.CoachBaseLevel")
local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")

local AssistantCoachSystemModel = class(Model, "AssistantCoachSystemModel")

function AssistantCoachSystemModel:ctor()
    self.mainCoach = nil
    self.coachData = nil -- 教练的信息
    self.assistantCoachDatas = nil -- 助理教练信息
    self.assistantCoachModels = {} -- 助理教练model

    self.maxTeams = 0 -- 一个教练携带助理教练最大数
    self.currMaxTeams = 0 -- 当前教练等级下可携带助理教练最大数
    self.currTeamIndex = nil

    self.teams = nil -- 助理团队的页签的数据
end

function AssistantCoachSystemModel:InitWithProtocol(assistantCoachDatas, mainCoach)
    self.mainCoach = mainCoach
    self.coachData = mainCoach.coach
    self.assistantCoachDatas = assistantCoachDatas or {}
    self.assistantCoachModels = {}

    self.currMaxTeams = CoachBaseLevel[tostring(self.coachData.lvl)].assistantCoachAmount
    self.maxTeams = self.currMaxTeams
    for k, v in pairs(CoachBaseLevel) do
        if self.maxTeams < v.assistantCoachAmount then
            self.maxTeams = v.assistantCoachAmount
        end
    end

    self:ParseTeamsData()
    self:ParseAssistantCoachModels()
end

function AssistantCoachSystemModel:ParseTeamsData()
    -- 遍历教练配置，获得助理教练解锁信息
    local tempCoachConfig = {}
    for k, v in pairs(CoachBaseLevel) do
        v.id = k
        table.insert(tempCoachConfig, v)
    end
    table.sort(tempCoachConfig, function(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end)
    local assistUnlockInfo = {} -- {assistantCoachAmount = id}
    local lastAssistAmount = 0
    for k, v in ipairs(tempCoachConfig) do
        if tonumber(v.assistantCoachAmount) > lastAssistAmount then
            assistUnlockInfo[tostring(v.assistantCoachAmount)] = v.id
            lastAssistAmount = tonumber(v.assistantCoachAmount)
        end
    end

    self.teams ={}
    for i = 1, self.maxTeams do
        local value = {}
        value.idx = i
        value.name = lang.transstr("assistant_coach_team", i)
        value.isLocked = i > self.currMaxTeams
        local tempId = assistUnlockInfo[tostring(i)]
        if not tempId then
            for amount, id in pairs(assistUnlockInfo) do -- 防止出现升一级教练解锁多个的情况
                if i < tonumber(amount) then
                    tempId = id
                    break
                end
            end
        end
        value.unlockInfo = CoachBaseLevel[tempId] or {}
        table.insert(self.teams, value)
    end
end

-- 解析数据从assistantCoachDatas生成assistantCoachModels
function AssistantCoachSystemModel:ParseAssistantCoachModels()
    self.assistantCoachModels = {}
    for team = 1, self.maxTeams do
        local acData = self.assistantCoachDatas.ac_teamlist[tostring(team)]
        if acData then
            local acModel = AssistantCoachModel.new()
            acModel:InitWithProtocol(acData)
            acModel:SetTeamIdx(team)
            self.assistantCoachModels[tostring(team)] = acModel
        end
    end
end

function AssistantCoachSystemModel:GetStatusData()
    return self.mainCoach, self:GetCurrTeamIndex()
end

function AssistantCoachSystemModel:GetAssistantCoachDatas()
    return self.assistantCoachDatas
end

-- 获得上方页签助教团队的列表
function AssistantCoachSystemModel:GetTeams()
    return self.teams or {}
end

-- 获得可携带最大助教团队数目
function AssistantCoachSystemModel:GetMaxTeam()
    return self.maxTeams
end

-- 获得当前教练等级下可携带助教团队数目
function AssistantCoachSystemModel:GetCurrMaxTeam()
    return self.currMaxTeams
end

-- 页面当前选中的助教团队的index
function AssistantCoachSystemModel:GetCurrTeamIndex()
    return self.currTeamIndex or 1
end

function AssistantCoachSystemModel:SetCurrTeamIndex(index)
    self.currTeamIndex = index
end

function AssistantCoachSystemModel:GetAssistantCoachModelByTeamIdx(teamIdx)
    return self.assistantCoachModels[tostring(teamIdx)]
end

-- 获得页面当前选中的助教的model
-- @return AssistantCoachModel
function AssistantCoachSystemModel:GetCurrAssistantCoachModel()
    return self:GetAssistantCoachModelByTeamIdx(self:GetCurrTeamIndex())
end

return AssistantCoachSystemModel
