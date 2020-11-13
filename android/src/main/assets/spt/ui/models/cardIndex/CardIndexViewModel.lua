local Model = require("ui.models.Model")
local Skills = require("data.Skills")
local SkillType = require("ui.common.enum.SkillType")
local Nation = require("data.Nation")
local CardIndexViewModel = class(Model, "CardIndexViewModel")
local DefaultNation = ""

function CardIndexViewModel:Init()
    self.skillList = nil
    self.skillMap = nil
    self:InitSkillViewData()
    self:InitNationData()
end

function CardIndexViewModel:InitViewData(model)
    self:SetRootData(model)
    self:SetViewData()
end

local HideLegendSkillIndex = 1
function CardIndexViewModel:InitSkillViewData()
    self.skillList = {}
    self.skillMap = {}
    for sid, skill in pairs(Skills) do
        local unShow = skill.unShow
        if skill.type == SkillType.EVENT and tonumber(unShow) ~= HideLegendSkillIndex then
            local skillData = {}
            skillData.skillID = skill.skillID
            skillData.name = skill.skillName
            skillData.picIndex = skill.picIndex
            skillData.type = skill.type
            skillData.isSelect = false
            self.skillMap[sid] = skillData
            table.insert(self.skillList, skillData)
        end
    end
end

function CardIndexViewModel:InitNationData()
    self.nationCounter = 0
    self.nationMap = {
        ["0"] = {DefaultNation},
    }
    self.nationDict = {}
    for nationID, nationData in pairs(Nation) do
        if self.nationMap[nationData.firstLetter] == nil then
            self.nationMap[nationData.firstLetter] = {}
        end
        local data = {}
        data.name = nationData.nation
        data.isShow = tonumber(nationData.display)
        data.index = nationData.order
        data.nationality = nationID
        self.nationMap[nationData.firstLetter][nationID] = data
        self.nationDict[nationID] = data
        if data.isShow == 1 then
            self.nationCounter = self.nationCounter + 1
        end
    end
    
    self.nationLetterCount = table.nums(self.nationMap)
end

function CardIndexViewModel:SetRootData(model)
    self.rootPsition = model:GetSelectPos()
    self.rootQuality = model:GetSelectQuality()
    self.rootPlayerName = model:GetSeletName()
    self.rootNationality = model:GetSeletNationality()
    self.rootNationData = self.nationDict[self.rootNationality]
    self.rootSkill = model:GetSeletSkill()
    self.rootSkillSelectMap = {}
    for k, v in pairs(self.rootSkill) do
        self.rootSkillSelectMap[k] = v
    end
end

function CardIndexViewModel:SetViewData()
    self.viewPosition = clone(self.rootPsition)
    self.viewQuality = clone(self.rootQuality)
    self.viewPlayerName = self.rootPlayerName
    self.viewNationality = self.rootNationality
    self.viewNationData = self.nationDict[self.viewNationality]
    self.viewSkill = clone(self.rootSkill)
    self.viewNationData = clone(self.rootNationData)
    self.viewSkillSelectMap = clone(self.rootSkillSelectMap)
end

function CardIndexViewModel:CancelSelect()
    self:SetViewData()
end

--- 获取技能列表
function CardIndexViewModel:GetSkillList()
    return self.skillList
end

--- 获取国籍列表
function CardIndexViewModel:GetNationMap()
    return self.nationMap
end

--- 暂存筛选国籍显示数据
function CardIndexViewModel:SetSeletNationData(data)
    self.viewNationality = data and data.nationality or ""
    self.viewNationData = data
end
--- 获取筛选国籍显示数据
function CardIndexViewModel:GetSeletNationData()
    return self.viewNationData
end
--- 保存国籍显示数据
function CardIndexViewModel:SetSeletNationConfirmData()
    self.rootNationData = self.viewNationData
    self.rootNationality = self.rootNationData and self.rootNationData.nationality or ""
end
--- 暂存技能筛选显示数据
function CardIndexViewModel:SetSeletSkillDataMap(data)
    self.viewSkill = {}
    if data then
        self.viewSkillSelectMap = data
    end
    for k, v in pairs(self.viewSkillSelectMap) do
        table.insert(self.viewSkill, v.skillID)
    end
end

--- 获取技能筛选显示数据
-- return table(default {})
function CardIndexViewModel:GetSeletSkillDataMap()
    return self.viewSkillSelectMap or {}
end
--- 保存技能显示数据
function CardIndexViewModel:SetSeletSkillConfirmData()
    self.rootSkillSelectMap = self.viewSkillSelectMap
end

function CardIndexViewModel:GetSkillData(sid)
    return self.skillMap[sid]
end

function CardIndexViewModel:GetViewPosition()
    return self.viewPosition
end

function CardIndexViewModel:GetViewQuality()
    return self.viewQuality
end

function CardIndexViewModel:GetViewPlayerName()
    return self.viewPlayerName
end

function CardIndexViewModel:GetViewNationality()
    return self.viewNationality
end

function CardIndexViewModel:GetViewSkill()
    return self.viewSkill
end

function CardIndexViewModel:SetViewPlayerName(playerName)
    self.viewPlayerName = playerName
end

return CardIndexViewModel