local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerTreasureCountRewardView = class(unity.base)

function PlayerTreasureCountRewardView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.title = self.___ex.title
    self.rewardScroll = self.___ex.rewardScroll
    self.scrollRect = self.___ex.scrollRect

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function PlayerTreasureCountRewardView:InitView(playerTreasureModel)
    local countRewardList = playerTreasureModel:GetCountList()
    rewardPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/TreasureCountRewardItem.prefab"
    res.ClearChildren(self.rewardScroll)
    for i,v in ipairs(countRewardList) do
        local rewardObj, rewardSpt = res.Instantiate(rewardPath)
        rewardObj.transform:SetParent(self.rewardScroll, false)
        rewardSpt.scrollRect = self.scrollRect
        rewardSpt:InitView(v, self.collectCallBack)
    end
end

function PlayerTreasureCountRewardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return PlayerTreasureCountRewardView