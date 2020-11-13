local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local RewardListScrollView = class(LuaScrollRectExSameSize)

function RewardListScrollView:ctor()
    RewardListScrollView.super.ctor(self)
end

function RewardListScrollView:start()
end

function RewardListScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Rewards/RewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function RewardListScrollView:resetItem(spt, index)
    local rewardModel = self.data[index]
    spt:InitView(rewardModel)
    spt.clickReceive = function() self:OnReceiveClick(rewardModel:GetRewardID()) end
    self:updateItemIndex(spt, index)
end

function RewardListScrollView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

function RewardListScrollView:OnReceiveClick(rewardID)
    if self.clickReward then
        self.clickReward(rewardID)
    end
end

return RewardListScrollView
