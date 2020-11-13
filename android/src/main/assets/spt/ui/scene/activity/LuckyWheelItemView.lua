local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local RectTransform = UnityEngine.RectTransform

local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')

local LuckyWheelItemView = class(unity.base)

function LuckyWheelItemView:ctor()
    self.iconFlash = self.___ex.iconFlash
    self.iconReward = self.___ex.iconReward
    self.animator = self.___ex.animator
end

function LuckyWheelItemView:InitView(itemData)
    local rewardParams = {
        parentObj = self.iconReward.transform,
        rewardData = itemData,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    -- 处理下球员碎片的尺寸
    if type(itemData.cardPiece) == "table" and next(itemData.cardPiece) then
        local cardPieceRectTrans = self.iconReward.transform:GetChild(0):GetComponent(RectTransform)
        cardPieceRectTrans.sizeDelta = Vector2(85, 100)
    end
end

function LuckyWheelItemView:SetHighlight()
    self.animator:Play("LuckWheelRunAnimation", 0, 0)
end

function LuckyWheelItemView:SetShining()
    self.animator:SetTrigger("shiningTrig")
end

function LuckyWheelItemView:SetDefault()
    self.animator:Play("LuckWheelDefaultAnimation", 0, 0)
end

return LuckyWheelItemView
