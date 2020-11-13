local Model = require("ui.models.Model")
local Data = require("data.DreamLeagueDailyReward")

local DreamDailyRewardModel = class(Model, "DreamDailyRewardModel")

function DreamDailyRewardModel:ctor()
end

function DreamDailyRewardModel:GetScrollData()
    self.dataList = {}
    for k, v in pairs(Data) do
        table.insert(self.dataList, v)
    end

    table.sort(self.dataList, function(a, b)
        if a.id < b.id then
            return true
        else
            return false
        end
    end)

    return self.dataList
end

return DreamDailyRewardModel