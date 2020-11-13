local Model = require("ui.models.Model")

local CompeteRewardModel = class(Model, "CompeteRewardModel")

function CompeteRewardModel:ctor(data)
    CompeteRewardModel.super.ctor(self)
    self.rewardList = data.rewardList
    if not self.rewardList then
        dump("error:    rewardList is nil!!!")
    end
end

function CompeteRewardModel:InitWithProtocol()
    
end

function CompeteRewardModel:GetMailList()    
    return self.rewardList or {}
end

return CompeteRewardModel
