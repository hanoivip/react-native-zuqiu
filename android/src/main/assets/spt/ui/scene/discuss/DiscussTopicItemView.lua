local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local LuaButton = require("ui.control.button.LuaButton")

local DiscussTopicItemView = class(LuaButton)

function DiscussTopicItemView:ctor()
    DiscussTopicItemView.super.ctor(self)
    self.topicName = self.___ex.topicName
    self.topicContent = self.___ex.topicContent
    self.lastTime = self.___ex.lastTime
    self.topicBtn = self.___ex.topicBtn
    self.itemParent = self.___ex.itemParent
    self.rewardText = self.___ex.rewardText

    self.topicNameRct = self.___ex.topicNameRct
    self.topicNameFrame = self.___ex.topicNameFrame
end

function DiscussTopicItemView:Init(topicHotItemData, index)
    self.topicName.text = topicHotItemData.title
    self.lastTime.text = lang.transstr("time_discuss",topicHotItemData.beginTime, topicHotItemData.endTime)
    self.topicContent.text = topicHotItemData.desc
    self.rewardText.text = lang.transstr("reward_discuss",topicHotItemData.rewardNum)
    res.ClearChildren(self.itemParent)
    local rewardParams = {
        parentObj = self.itemParent,
        rewardData = topicHotItemData.contents,
        isShowName = false,
        isReceive = false,
        hideCount = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowSymbol = false,
    }
    RewardDataCtrl.new(rewardParams)

    self:UpdateTopicNameScrolling()
end

function DiscussTopicItemView:UpdateTopicNameScrolling()
    if self.tweener then 
        TweenExtensions.Restart(self.tweener)
        self.topicNameRct.anchoredPosition = Vector2(0, 0)
    end
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        local nameWidth = self.topicNameRct.rect.width
        if nameWidth > self.topicNameFrame.rect.width then
            local scrollSpeed = 80
            self.topicNameRct.anchoredPosition = Vector2(self.topicNameFrame.rect.width, 0)
            local time = (self.topicNameFrame.rect.width + nameWidth) / scrollSpeed
            self.tweener = ShortcutExtensions.DOAnchorPosX(self.topicNameRct, -nameWidth, time)
            TweenSettingsExtensions.SetEase(self.tweener, Ease.Linear)
            TweenSettingsExtensions.SetLoops(self.tweener, -1)
        end
    end)
end

return DiscussTopicItemView
