local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LadderRewardDetailItemView = class(unity.base, "LadderRewardDetailItemView")

local cardPieceReward = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemCardPieceReward.prefab"
local cardReward = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemCardReward.prefab"
local itemReward = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemItemReward.prefab"
local moneyReward = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemMoneyReward.prefab"

function LadderRewardDetailItemView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.txtNormalRank = self.___ex.txtNormalRank
    self.rewardContainer = self.___ex.rewardItems
end

function LadderRewardDetailItemView:InitView(data)
    local rankLow = data.rankLow
    local rankHigh = data.rankHigh
    self:SetRankShowStatus(rankLow, rankHigh)

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

function LadderRewardDetailItemView:SetRankShowStatus(rankLow, rankHigh)
    local isTopThree, isFirst, isSecond, isThird = true, false, false, false
    if rankLow == 1 and rankHigh == 1 then 
        isFirst = true
    elseif rankLow == 2 and rankHigh == 2 then 
        isSecond = true
    elseif rankLow == 3 and rankHigh == 3 then 
        isThird = true
    else
        isTopThree = false
        local rankStr
        if rankHigh == rankLow then 
            rankStr = lang.trans("ladder_rewardDetail_rank2", tostring(rankHigh))
        else
            rankStr = lang.trans("ladder_rewardDetail_rank", tostring(rankHigh), tostring(rankLow))
        end
        self.txtNormalRank.text = rankStr
    end

    GameObjectHelper.FastSetActive(self.firstRank, isFirst)
    GameObjectHelper.FastSetActive(self.secondRank, isSecond)
    GameObjectHelper.FastSetActive(self.thirdRank, isThird)
    GameObjectHelper.FastSetActive(self.normalRank, not isTopThree)
end

function LadderRewardDetailItemView:ClearRewardItems()
    local count = self.rewardContainer.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.rewardContainer:GetChild(i).gameObject)
    end
end

return LadderRewardDetailItemView