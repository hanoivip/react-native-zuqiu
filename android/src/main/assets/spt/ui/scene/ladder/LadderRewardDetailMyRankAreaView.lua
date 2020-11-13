local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LadderRewardDetailMyRankAreaView = class(unity.base, "LadderRewardDetailMyRankAreaView")

local cardPieceReward = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemCardPieceReward.prefab"
local cardReward = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemCardReward.prefab"
local itemReward = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemItemReward.prefab"
local moneyReward = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemMoneyReward.prefab"

function LadderRewardDetailMyRankAreaView:ctor()
    self.rewardContainer = self.___ex.rewardItems
end

function LadderRewardDetailMyRankAreaView:InitView(data)

    if data.contents then
        if data.contents.cardPiece then
            for k, v in pairs(data.contents.cardPiece) do
                local obj, spt = res.Instantiate(cardPieceReward)
                obj.transform:SetParent(self.rewardContainer, false)
                spt:InitView(v)
            end
        end
        if data.contents.card then
            for k, v in pairs(data.contents.card) do
                local obj, spt = res.Instantiate(cardReward)
                obj.transform:SetParent(self.rewardContainer, false)
                spt:InitView(v)
            end
        end
        if data.contents.item then
            for k, v in pairs(data.contents.item) do
                local obj, spt = res.Instantiate(itemReward)
                obj.transform:SetParent(self.rewardContainer, false)
                spt:InitView(v)
            end
        end
        if data.contents.m then
            local obj, spt = res.Instantiate(moneyReward)
            obj.transform:SetParent(self.rewardContainer, false)
            spt:InitView(data.contents.m)
        end
    end
end

function LadderRewardDetailMyRankAreaView:ClearItemBox()
    local count = self.rewardContainer.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.rewardContainer:GetChild(i).gameObject)
    end
end

return LadderRewardDetailMyRankAreaView
