local AdventureRewardBase = require("data.AdventureRewardBase")
local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local TreasureEventModel = class(GeneralEventModel, "TreasureEventModel")

function TreasureEventModel:ctor()
    TreasureEventModel.super.ctor(self)
end

function TreasureEventModel:InitWithProtocolReward(rewardData)
    self.rewardData = {}
    for i, v in ipairs(rewardData) do
        local r = AdventureRewardBase[tostring(v)]
        if r then
            table.insert(self.rewardData, r)
        end
    end
end

function TreasureEventModel:GetRewardData()
    return self.rewardData or {}
end

function TreasureEventModel:HasTweenExtension()
    return true
end

return TreasureEventModel