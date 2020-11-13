local GameObjectHelper = require("ui.common.GameObjectHelper")
local FriendsInviteMenuType = require("ui.models.friends.FriendsInviteMenuType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local RewardStatus = require("ui.models.friends.RewardStatus")

local FriendsInviteScrollItemView = class(unity.base)

function FriendsInviteScrollItemView:ctor()
    self.finishIcon = self.___ex.finishIcon
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnDiable = self.___ex.rewardBtnDiable
    self.frdsCountParentRect = self.___ex.frdsCountParentRect
    self.frdsLvlParentRect = self.___ex.frdsLvlParentRect
    self.frdsChargeParentRect = self.___ex.frdsChargeParentRect
    self.frdsCountDescTxt = self.___ex.frdsCountDescTxt
    self.frdsLvlDescTxt = self.___ex.frdsLvlDescTxt
    self.frdsChargeDescTxt = self.___ex.frdsChargeDescTxt
    self.frdsCountObj = self.___ex.frdsCountObj
    self.frdsLvlObj = self.___ex.frdsLvlObj
    self.frdsChargeObj = self.___ex.frdsChargeObj
    self.frdsLvlCumulativeConsumeItemScrollAtOnce = self.___ex.frdsLvlCumulativeConsumeItemScrollAtOnce
    self.frdsChargeCumulativeConsumeItemScrollAtOnce = self.___ex.frdsChargeCumulativeConsumeItemScrollAtOnce
    self.frdsCountCumulativeConsumeItemScrollAtOnce = self.___ex.frdsCountCumulativeConsumeItemScrollAtOnce

    self.descTxts = {self.frdsCountDescTxt, self.frdsLvlDescTxt, self.frdsChargeDescTxt}
    self.parentRects = {self.frdsCountParentRect, self.frdsLvlParentRect, self.frdsChargeParentRect}
    self.cumulativeConsumeItemScrollAtOnces = {self.frdsCountCumulativeConsumeItemScrollAtOnce, self.frdsLvlCumulativeConsumeItemScrollAtOnce, self.frdsChargeCumulativeConsumeItemScrollAtOnce}
end

function FriendsInviteScrollItemView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

function FriendsInviteScrollItemView:InitView(itemModel, friendsInviteModel, parentScrollRect)
    self.itemModel = itemModel
    self.friendsInviteModel = friendsInviteModel

    local menuType = self.friendsInviteModel:GetCurrentMenu()
    self:InitRewardButtonState()
    self:ShowViewOfTaskType()
    local taskType = self.itemModel:GetTaskType()
    res.ClearChildren(self.cumulativeConsumeItemScrollAtOnces[taskType].gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRects[taskType],
        rewardData = self.itemModel:GetContents(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    self:InitDescTxt(taskType, menuType)

    self.cumulativeConsumeItemScrollAtOnces[taskType].scrollRectInParent = parentScrollRect
end

function FriendsInviteScrollItemView:InitDescTxt(taskType, menuType)
    local descStr = self.itemModel:GetTaskDesc()

    local firstParam = self.itemModel:GetTaskFirstParam()
    if menuType == FriendsInviteMenuType.FRIENDS_NUM or menuType == FriendsInviteMenuType.FRIENDS_CHARGE then
        descStr = string.format(descStr, firstParam, self.itemModel:GetProgressValue(), firstParam)
    elseif menuType == FriendsInviteMenuType.FRIENDS_LVL then
        local secondParam = self.itemModel:GetTaskSecondParam()
        descStr = string.format(descStr, firstParam, secondParam, self.itemModel:GetProgressValue(), firstParam)
    end
    self.descTxts[taskType].text = descStr
end

function FriendsInviteScrollItemView:InitRewardButtonState()
    GameObjectHelper.FastSetActive(self.finishIcon, self.itemModel:IsRewardAlreadyCollected())
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, self.itemModel:IsRewardCollectable())
    GameObjectHelper.FastSetActive(self.rewardBtnDiable, self.itemModel:IsRewardInComplete())
end

function FriendsInviteScrollItemView:ShowViewOfTaskType()
    local menuType = self.friendsInviteModel:GetCurrentMenu()
    GameObjectHelper.FastSetActive(self.frdsCountObj, menuType == FriendsInviteMenuType.FRIENDS_NUM)
    GameObjectHelper.FastSetActive(self.frdsLvlObj, menuType == FriendsInviteMenuType.FRIENDS_LVL)
    GameObjectHelper.FastSetActive(self.frdsChargeObj, menuType == FriendsInviteMenuType.FRIENDS_CHARGE)
end



function FriendsInviteScrollItemView:OnRewardBtnClick()
    self:coroutine(function()
        local response = req.fiCollectOtherTaskReward(self.itemModel:GetTaskID())
        if api.success(response) then
            local data = response.val
            if type(data) == "table" and data.contents then
                CongratulationsPageCtrl.new(data.contents)
                self.itemModel:SetOtherTaskRewardStatus(RewardStatus.COLLECTED)
                self:InitRewardButtonState()

                local currentMenuType = self.friendsInviteModel:GetCurrentMenu()
                local currentTabTag = self.friendsInviteModel:GetCurrentTabTag()
                local hasRewardNotCollected = self.friendsInviteModel:HasRewardNotCollected(currentMenuType)
                EventSystem.SendEvent("TabItem_RefreshRedPoint", currentTabTag, hasRewardNotCollected)
            end
        end
    end)
end

function FriendsInviteScrollItemView:onDestroy()
end

return FriendsInviteScrollItemView