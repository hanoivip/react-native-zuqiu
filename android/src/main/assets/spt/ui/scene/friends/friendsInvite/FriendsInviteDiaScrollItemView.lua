local GameObjectHelper = require("ui.common.GameObjectHelper")
local FriendsInviteMenuType = require("ui.models.friends.FriendsInviteMenuType")
local RewardStatus = require("ui.models.friends.RewardStatus")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local Timer = require('ui.common.Timer')

local FriendsInviteDiaScrollItemView = class(unity.base)

function FriendsInviteDiaScrollItemView:ctor()
    self.finishIcon = self.___ex.finishIcon
    self.rewardBtn = self.___ex.rewardBtn
    self.playerNameTxt = self.___ex.playerNameTxt
    self.playerLvlTxt = self.___ex.playerLvlTxt
    self.rewardTipTxt = self.___ex.rewardTipTxt
    self.logo = self.___ex.logo
    self.playerNameTxt = self.___ex.playerNameTxt
    self.playerLvlTxt = self.___ex.playerLvlTxt
    self.consumeDiaTxt = self.___ex.consumeDiaTxt
    self.rtnDiaTxt = self.___ex.rtnDiaTxt
end

function FriendsInviteDiaScrollItemView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

function FriendsInviteDiaScrollItemView:InitView(itemModel, friendsInviteModel, parentScrollRect)
    self.itemModel = itemModel
    self.friendsInviteModel = friendsInviteModel

    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self:InitPlayerInfoArea()
    self:InitDiamondArea()
    self:InitButtonAreaView()
end

function FriendsInviteDiaScrollItemView:InitPlayerInfoArea()
    TeamLogoCtrl.BuildTeamLogo(self.logo, self.itemModel:GetLogoData())
    self.playerNameTxt.text = self.itemModel:GetPlayerName()
    self.playerLvlTxt.text = "Lv" .. tostring(self.itemModel:GetPlayerLvl())
end

function FriendsInviteDiaScrollItemView:InitDiamondArea()
    self.consumeDiaTxt.text = "X" .. tostring(self.itemModel:GetConsumeDia())
    self.rtnDiaTxt.text = "X" .. tostring(self.itemModel:GetRtnDia())
end

function FriendsInviteDiaScrollItemView:InitButtonAreaView()
    if self.itemModel:IsDiamondCollected() then
        self:ShowViewOfDiffStatus(false, true, false)
    elseif self.itemModel:IsDiamondCollectable() then
        if self.itemModel:IsDiamondLessThanOne() then
            self:ShowViewOfDiffStatus(false, false, true)
            self.rewardTipTxt.text = lang.transstr("friendsInvite_desc9")
        else
            self:ShowViewOfDiffStatus(true, false, false)
        end
    else
        self:ShowViewOfDiffStatus(false, false, true)
        self:ShowCountDownTip()
    end
end

function FriendsInviteDiaScrollItemView:ShowCountDownTip()
    local intervalTime = self.itemModel:GetCountDownTime()
    if intervalTime <= 0 then
        self:InitButtonAreaView()
        return
    end
    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.countDownTimer = Timer.new(intervalTime, function(time)
        self.rewardTipTxt.text = lang.transstr("friendsInvite_desc10") .. string.convertSecondToTime(time)
        if time <= 0 then
            self:InitButtonAreaView()
            self:RefreshTabRedPoint()
        end
    end)
end

function FriendsInviteDiaScrollItemView:ShowViewOfDiffStatus(isShowRewardBtn, isShowFinishIcon, isShowRewardTip)
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, isShowRewardBtn)
    GameObjectHelper.FastSetActive(self.finishIcon, isShowFinishIcon)
    GameObjectHelper.FastSetActive(self.rewardTipTxt.gameObject, isShowRewardTip)
end

function FriendsInviteDiaScrollItemView:OnRewardBtnClick()
    self:coroutine(function()
        local response = req.fiCollectDiaTaskReward(self.itemModel:GetOtherPlayerPID())
        if api.success(response) then
            local data = response.val
            if type(data) == "table" and data.d then
                local contents = {}
                contents.d = data.d
                CongratulationsPageCtrl.new(contents)
                self.itemModel:SetDiaTaskRewardStatus(data.rd)
                self:InitButtonAreaView()
                self:RefreshTabRedPoint()
            end
        end
    end)
end

function FriendsInviteDiaScrollItemView:RefreshTabRedPoint()
    local currentMenuType = self.friendsInviteModel:GetCurrentMenu()
    local currentTabTag = self.friendsInviteModel:GetCurrentTabTag()
    local hasRewardNotCollected = self.friendsInviteModel:HasRewardNotCollected(currentMenuType)
    EventSystem.SendEvent("TabItem_RefreshRedPoint", currentTabTag, hasRewardNotCollected)
end

function FriendsInviteDiaScrollItemView:onDestroy()
    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
end

return FriendsInviteDiaScrollItemView