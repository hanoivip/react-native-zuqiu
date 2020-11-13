local Model = require("ui.models.Model")

local CompeteChampionWallOverviewModel = class(Model, "CompeteChampionWallOverviewModel")

function CompeteChampionWallOverviewModel:ctor()
    self.data = nil
    self.label = nil -- 0不接受，1接受
end

function CompeteChampionWallOverviewModel:InitWithParent(bigEar, smallEar)
    self.bigEar = {}
    self.smallEar = {}
    self:PolishData(bigEar, self.bigEar)
    self:PolishData(smallEar, self.smallEar)
end

function CompeteChampionWallOverviewModel:PolishData(rawData, targetList)
    for pid, v in pairs(rawData) do
        table.insert(targetList, v)
    end
    table.sort(targetList, function(a, b)
        return a.count > b.count
    end)
    local rank = 1
    local lastCount = -1
    for idx, v in ipairs(targetList) do
        v.idx = idx
        if lastCount > 0 then
            if v.count ~= lastCount then
                rank = idx
            end
        end
        v.rank = rank
        lastCount = v.count
    end
end

function CompeteChampionWallOverviewModel:GetBigEarData()
    return self.bigEar
end

function CompeteChampionWallOverviewModel:GetSmallEarData()
    return self.smallEar
end

return CompeteChampionWallOverviewModel
