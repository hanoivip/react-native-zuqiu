local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CommonConstants = require("ui.common.CommonConstants")
local PeakRuleSeasonRewardItemView = class(unity.base)

function PeakRuleSeasonRewardItemView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.contentTrans = self.___ex.contentTrans
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce
    self.prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakRuleSeasonRewardSplit.prefab"
end

function PeakRuleSeasonRewardItemView:InitView(data, scrollRectParent)
    self:InitRank(data)
    self:InitRewardContent(data)
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = scrollRectParent
end

function PeakRuleSeasonRewardItemView:InitRewardContent(data)
    res.ClearChildren(self.contentTrans)
    local splitContents = self:SplitContents(data.contents)
    for i,v in ipairs(splitContents) do
        local rewardSplitObj, rewardSplitView = res.Instantiate(self.prefabPath)
        rewardSplitObj.transform:SetParent(self.contentTrans, false)
        rewardSplitView:InitView(v)
    end
end

function PeakRuleSeasonRewardItemView:InitRank(data)
    GameObjectHelper.FastSetActive(self.firstRank, tonumber(data.low) == 1)
    GameObjectHelper.FastSetActive(self.secondRank, tonumber(data.low) == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, tonumber(data.low) == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, tonumber(data.low) ~= 1 and tonumber(data.low) ~= 2 and tonumber(data.low) ~= 3)
    if data.low == data.high then
        self.normalRank.text = lang.trans("league_rank", data.low)
    else
        if data.high == 0 then
            self.normalRank.text = lang.trans("peak_rank_range_1", data.low)
        else
            self.normalRank.text = lang.trans("peak_rank_range", data.low, data.high)
        end
    end
end

function PeakRuleSeasonRewardItemView:SplitContents(contents)
    local items = {}
    for itemType,itemValue in pairs(contents) do
        if type(itemValue) == "table" then
            for index,itemContent in ipairs(itemValue) do
                local temp = {}
                temp[itemType] = {itemContent}
                table.insert(items, temp)
            end
        else
            local temp = {}
            temp[itemType] = itemValue
            table.insert(items, temp)
        end
    end
    return items
end


return PeakRuleSeasonRewardItemView