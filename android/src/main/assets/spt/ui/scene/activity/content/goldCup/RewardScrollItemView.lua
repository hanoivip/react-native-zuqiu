local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardScrollItemView = class(unity.base)

local arrowShowThreshold = 3
function RewardScrollItemView:ctor()
    self.scrollDragSpt = self.___ex.scrollDragSpt
    self.deepColorBg = self.___ex.deepColorBg
    self.delicateColorBg = self.___ex.delicateColorBg
    self.rankTxt = self.___ex.rankTxt
    self.scrollRect = self.___ex.scrollRect
    self.lArrow = self.___ex.lArrow
    self.rArrow = self.___ex.rArrow
    self.content = self.___ex.content

    self:BindScrollFunc()
end

function RewardScrollItemView:InitView(itemModel)
    self.itemModel = itemModel

    local itemIndex = self.itemModel:GetItemIndex()
    GameObjectHelper.FastSetActive(self.delicateColorBg, itemIndex % 2 == 0)
    GameObjectHelper.FastSetActive(self.deepColorBg, itemIndex % 2 ~= 0)

    self.rankTxt.text = self.itemModel:GetRankStr()

    self:InitRewardContentAndArrows()
end

function RewardScrollItemView:InitRewardContentAndArrows()
    GameObjectHelper.FastSetActive(self.lArrow, false)
    GameObjectHelper.FastSetActive(self.rArrow, self.itemModel:IsArrowsShow(arrowShowThreshold))

    local rewardContents = self.itemModel:GetRewardContents()
    res.ClearChildren(self.content)
    local rewardParams = {
        parentObj = self.content,
        rewardData = rewardContents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowSymbol = false,
        isShowCardPieceBeforeItem = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function RewardScrollItemView:BindScrollFunc()
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

function RewardScrollItemView:UpdateArrowState(isShowL, isShowR)
    GameObjectHelper.FastSetActive(self.lArrow, isShowL)
    GameObjectHelper.FastSetActive(self.rArrow, isShowR)
end

return RewardScrollItemView
