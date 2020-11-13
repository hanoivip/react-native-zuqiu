local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AdventureRegion = require("data.AdventureRegion")

local RewardReviewIntroduceView = class(unity.base, "RewardReviewIntroduceView")

function RewardReviewIntroduceView:ctor()
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------

    self.scrollRect = self.___ex.scrollRect
    self.itemPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/RewardReviewItem.prefab"
end

function RewardReviewIntroduceView:InitView()
    if not self.itemSpt then
        self.itemSpt = {}
        local rewardData = self:SortRewardData()
        local itemRes = res.LoadRes(self.itemPath)
        for i, v in ipairs(rewardData) do
            local obj = Object.Instantiate(itemRes)
            local regionID = v.regionID
            obj.transform:SetParent(self.contentTrans, false)
            self.itemSpt[regionID] = obj:GetComponent("CapsUnityLuaBehav")
            self.itemSpt[regionID]:InitView(v, self.scrollRect)
        end
    end
end

function RewardReviewIntroduceView:SortRewardData()
    local rewardData = {}
    local adventureRegion = clone(AdventureRegion)
    for i, v in pairs(adventureRegion) do
        v.regionID = tonumber(i)
        table.insert(rewardData, v)
    end
    table.sort(rewardData, function(a, b) return a.regionID > b.regionID end)
    return rewardData
end

return RewardReviewIntroduceView
