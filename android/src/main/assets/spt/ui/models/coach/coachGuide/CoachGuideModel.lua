local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachGuidePrice = require("data.CoachGuidePrice")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local CoachGuideSlotState = require("ui.scene.coach.coachGuide.CoachGuideSlotState")
local Model = require("ui.models.Model")

local CoachGuideModel = class(Model, "CoachGuideModel")

-- 滚动列表最少8个 不够的用空的填充
local MinScrollCount = 8
-- 每一行是4个  保证整行数 不能有空缺
local RowCount = 4

function CoachGuideModel:ctor()
    self.super.ctor(self)
    self.coachMainModel = CoachMainModel.new()
    self.playerInfoModel = PlayerInfoModel.new()
    local coachGuideData = self.coachMainModel:GetCoachGuideData()
    self:Init(coachGuideData)
end

function CoachGuideModel:Init(data)
    if data then
        self.data = data
        self.coachMainModel:SetCoachGuideData(data)
    end
end

function CoachGuideModel:InitWithProtocol(data)
    self:Init(data.guide)
end

function CoachGuideModel:GetMaxCoachGuideSlotCount()
    local coachLevel = self.coachMainModel:GetCoachLevel()
    coachLevel = tostring(coachLevel)
    local coachGuideAmount = CoachBaseLevel[coachLevel].coachGuideAmount
    return coachGuideAmount
end

function CoachGuideModel:GetMaxCoachGuideDesc()
    local coachLevel = self.coachMainModel:GetCoachLevel()
    coachLevel = tostring(coachLevel)
    local guideDesc = CoachBaseLevel[coachLevel].guideDesc
    return guideDesc or ""
end

--  整理配表数据和服务器数据
function CoachGuideModel:GetCoachGuideSlotsList()
    local guideSlots = {}
    for k,v in pairs(CoachGuidePrice) do
        local tempSlotData = clone(v)
        local slotId = tempSlotData.id
        local slotStateData = self:GetSlotState(slotId)
        tempSlotData.slotStateData = slotStateData
        table.insert(guideSlots, tempSlotData)
    end
    table.sort(guideSlots, function(a, b) return a.id < b.id end)

    local maxCount = self:GetMaxCount(guideSlots)
    local fixedSlots = {}
    for i = 1, maxCount do
        table.insert(fixedSlots, guideSlots[i])
    end
    return fixedSlots
end

-- 筛选出符合条件的slot数量 最少8个  大于8个的之外的要是4的倍数
function CoachGuideModel:GetMaxCount(slotsList)
    local enableSlotIndex = 0
    local isFullUnlock = true
    for i,v in ipairs(slotsList) do
        local slotState = v.slotStateData.state
        if slotState == CoachGuideSlotState.Disable then
            enableSlotIndex = i - 1
            isFullUnlock = false
            break
        end
    end
    if isFullUnlock then enableSlotIndex = #slotsList end
    if enableSlotIndex <= MinScrollCount then
        return MinScrollCount
    else
        local line = math.modf(enableSlotIndex / RowCount)
        local mod = math.fmod(enableSlotIndex, RowCount)
        if mod > 0 then
            line = line + 1
        end
        return RowCount * line
    end
end

function CoachGuideModel:GetSlotState(slotId)
    local maxSlotCount = self:GetMaxCoachGuideSlotCount()
    local slotIdNum = tonumber(slotId)
    local slotIdStr = tostring(slotId)
    local slotStateData = {}
    if slotIdNum > maxSlotCount then
        slotStateData.state = CoachGuideSlotState.Disable
        return slotStateData
    end
    if self.data[slotIdStr] then
        slotStateData = self.data[slotIdStr]
        if slotStateData.pcid then
            slotStateData.state = CoachGuideSlotState.Used
            return slotStateData
        else
            slotStateData.state = CoachGuideSlotState.Unlock
            return slotStateData
        end
    else
        local nextUnlockIndex = self:GetUnlockSlotCount() + 1
        if slotIdNum == nextUnlockIndex then
            slotStateData.state = CoachGuideSlotState.Lock
        else
            slotStateData.state = CoachGuideSlotState.CanNotBuy
        end
        return slotStateData
    end
end

-- 已解锁的栏位数量
function CoachGuideModel:GetUnlockSlotCount()
    if self.data then
        return table.nums(self.data)
    end
    return 0
end

function CoachGuideModel:GetSlotPcids()
    local pcidList = {}
    for k,v in pairs(self.data) do
        if v.pcid then
            pcidList[tostring(v.pcid)] = true
        end
    end
    return pcidList
end

function CoachGuideModel:GetCoachLevelName()
    local coachLevel = self.coachMainModel:GetCoachLevel()
    coachLevel = tostring(coachLevel)
    local coachName = CoachBaseLevel[coachLevel].coachName
    return coachName
end

return CoachGuideModel
