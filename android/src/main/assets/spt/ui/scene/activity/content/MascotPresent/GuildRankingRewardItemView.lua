local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildRankingRewardItemView = class(unity.base)

local arrowShowThreshold  = 4
function GuildRankingRewardItemView:ctor()
    self.content = self.___ex.content
    self.rArrow = self.___ex.rArrow
    self.lArrow = self.___ex.lArrow
    self.rankText = self.___ex.rankText
    self.scrollRect = self.___ex.scrollRect
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce

    self.scrollRect.onValueChanged:AddListener(function(vector2)
        if self.itemModel:IsArrowsShow(arrowShowThreshold) then
            if vector2.x > 0.999 then
                self:UpdateArrowState(true, false)
            elseif vector2.x < 0.001 then
                self:UpdateArrowState(false, true)
            else
                self:UpdateArrowState(true, true)
            end
        end
    end)
end

function GuildRankingRewardItemView:InitView(itemModel, parentRect, activityModel)
    self.activityModel = activityModel
    self.itemModel = itemModel
    res.ClearChildren(self.content)

    GameObjectHelper.FastSetActive(self.lArrow, false)
    GameObjectHelper.FastSetActive(self.rArrow, self.itemModel:IsArrowsShow(arrowShowThreshold))
    self.rankText.text = tostring(self.itemModel:GetRankStr())
    local rewardParams = {
        parentObj = self.content,
        rewardData = self.itemModel:GetContents(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentRect
    RewardDataCtrl.new(rewardParams)
end

function GuildRankingRewardItemView:UpdateArrowState(isShowL, isShowR)
    GameObjectHelper.FastSetActive(self.lArrow, isShowL)
    GameObjectHelper.FastSetActive(self.rArrow, isShowR)
end

function GuildRankingRewardItemView:start()
end

function GuildRankingRewardItemView:onDestroy()
end

return GuildRankingRewardItemView
