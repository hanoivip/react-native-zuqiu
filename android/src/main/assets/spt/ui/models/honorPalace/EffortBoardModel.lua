local Model = require("ui.models.Model")

local EffortBoardModel = class(Model)

function EffortBoardModel:InitWithProtocol(data)
    assert(data)
    self.cachedata = data
end

function EffortBoardModel:GetSelfRank()
    local rank = self.cachedata.selfRank
    if tonumber(rank) == -1 then
        return lang.transstr("train_rankOut")
    end
    return rank
end

function EffortBoardModel:GetSelfEffortLevel()
    return self.cachedata.level
end

function EffortBoardModel:GetEffortData()
    local topTable = clone(self.cachedata.top)
    for i, v in ipairs(topTable) do
        v.rank = i
    end
    return topTable
end

return EffortBoardModel