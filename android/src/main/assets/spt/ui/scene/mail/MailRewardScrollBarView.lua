local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local MailRewardScrollBarView = class(unity.base)

function MailRewardScrollBarView:ctor()
    self.rewardIcon = self.___ex.rewardIcon
    self.rewardText = self.___ex.rewardText
end

function MailRewardScrollBarView:InitViewWithoutIcon(rewardTable, rewardType)
    local rewardName = self:GetName(rewardTable, rewardType)
    self.rewardText.text = tostring(rewardName) .. " x " .. tostring(rewardTable.num)
    GameObjectHelper.FastSetActive(self.rewardIcon.gameObject, false)
end

function MailRewardScrollBarView:InitViewWithIcon(reward, rewardType)
    self:InitIcon(rewardType)
    if rewardType == CurrencyType.Money then
        reward = string.formatNumWithUnit(reward)
    end
    self.rewardText.text = "      x " .. tostring(reward)
    GameObjectHelper.FastSetActive(self.rewardIcon.gameObject, true)
end

function MailRewardScrollBarView:InitIcon(rewardType)
    local iconPath = CurrencyImagePath[rewardType] or ""
    self.rewardIcon.overrideSprite = res.LoadRes(iconPath)
    self.rewardIcon:SetNativeSize()
end

function MailRewardScrollBarView:GetName(rewardTable, rewardType)
    return RewardNameHelper.GetTypeName(rewardTable, rewardType)
end

return MailRewardScrollBarView
