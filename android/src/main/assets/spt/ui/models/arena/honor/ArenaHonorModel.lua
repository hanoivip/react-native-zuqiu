local ArenaHonor = require("data.ArenaHonor")
local HonorPageType = require("ui.scene.arena.honor.HonorPageType")
local Model = require("ui.models.Model")
local ArenaHonorModel = class(Model, "ArenaHonorModel")

function ArenaHonorModel:ctor()
    ArenaHonorModel.super.ctor(self)
end

function ArenaHonorModel:Init(data)
    self.data = data or {}
end

function ArenaHonorModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

local TypeIndex = {[HonorPageType.Total] = 0, [HonorPageType.Silver] = 1, [HonorPageType.Gold] = 2, [HonorPageType.BlackGold] = 3, [HonorPageType.Platina] = 4, [HonorPageType.Red] = 5, [HonorPageType.Yellow] = 6, [HonorPageType.Blue] = 7 }
function ArenaHonorModel:GetHonorData(pageType)
    local typeIndex = TypeIndex[pageType]
    local honorTable = {}
    for id, v in pairs(ArenaHonor) do
        v.id = tonumber(id)
        if v.type == typeIndex then 
            table.insert(honorTable, v)
        end
    end
    table.sort(honorTable, function(a, b) return a.id < b.id end)

    return honorTable
end

-- state 为 -1：未达成, 1：已达成，未领取, 100：已领取
function ArenaHonorModel:IsCanRecieve(id)
    local state = self.data[tostring(id)] and self.data[tostring(id)].state or 0
    return tobool(state == 1)
end

function ArenaHonorModel:IsBeRecieve(id)
    local state = self.data[tostring(id)] and self.data[tostring(id)].state or 0
    return tobool(state == 100)
end

function ArenaHonorModel:IsNotSatisfy(id)
    local state = self.data[tostring(id)] and self.data[tostring(id)].state or 0
    return tobool(state == -1)
end

function ArenaHonorModel:GetHonorDesc(id)
    return ArenaHonor[tostring(id)] and ArenaHonor[tostring(id)].desc
end

function ArenaHonorModel:SetRewardState(id, state)
    self.data[tostring(id)].state = state
    EventSystem.SendEvent("ArenaHonorChange", id)
end

return ArenaHonorModel