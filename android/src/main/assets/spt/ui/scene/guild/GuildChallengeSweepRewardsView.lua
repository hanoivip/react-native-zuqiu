local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local SweepBarCtrl = require("ui.controllers.quest.sweep.SweepBarCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ItemDetailModel = require("ui.models.itemDetail.ItemDetailModel")
local AssetFinder = require("ui.common.AssetFinder")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local GuildChallengeSweepRewardsView = class(unity.base)

function GuildChallengeSweepRewardsView:ctor()
    self.sweepContent = self.___ex.sweepContent
    self.confirmButton = self.___ex.confirmButton
    self.expNum = self.___ex.expNum
    self.debrisObj = self.___ex.debrisObj
    self.nameTxt = self.___ex.nameTxt
    self.countTxt = self.___ex.countTxt
    self.debrisImg = self.___ex.debrisImg
    self.canvasGroup = self.___ex.canvasGroup
end

local WaitTime = 0.5
function GuildChallengeSweepRewardsView:InitView(rewardData)
    self.rewardData = rewardData
    self:BuildRewardScroller()
end

function GuildChallengeSweepRewardsView:BuildRewardScroller()
    local rewardParams = {
        parentObj = self.sweepContent,
        rewardData = self.rewardData.contents,
        isShowName = true,
        isReceive = true,
        isShowBaseReward = true,
        isShowCardReward = false,
        isShowDetail = false,
    }
    RewardDataCtrl.new(rewardParams)
end

function GuildChallengeSweepRewardsView:start()
    self.confirmButton:regOnButtonClick(function()
        self:Close()
    end)
    self:ShowAnimation()
end

function GuildChallengeSweepRewardsView:ShowAnimation()
    local fadeInTweener = ShortcutExtensions.DOFade(self.canvasGroup, 0, WaitTime)
    TweenSettingsExtensions.From(fadeInTweener)
end

function GuildChallengeSweepRewardsView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end
    
function GuildChallengeSweepRewardsView:InitDebrisDate()
    local id = cache.getRequiredEquipId()
    local itemModel = nil
    if id then
        itemModel = ItemDetailModel.new(id)
    else
        return
    end
    local isHasCurrItem = self.sweepListModel:IsHasCurrItem(id)
    if not isHasCurrItem then return end

    self.debrisObj:SetActive(true)
    local need_num = itemModel:GetCompositePieceNum()
    local name = itemModel:GetName()
    local curr_num = itemModel:GetEquipPieceNum()
    self.nameTxt.text = itemModel:GetName()
    self.debrisImg.overrideSprite = AssetFinder.GetEquipIcon(id)

    if tonumber(need_num) == 1 then
        self.countTxt.text = lang.trans("sweepEqsCanWear")
        return
    end
    if need_num <= curr_num then
        self.countTxt.text = lang.trans("sweepEqsCanWear_1")
    else
        self.countTxt.text = lang.trans("sweepDebris", tostring(curr_num), tostring(need_num))
    end
end

function GuildChallengeSweepRewardsView:onDestroy()
end

return GuildChallengeSweepRewardsView
