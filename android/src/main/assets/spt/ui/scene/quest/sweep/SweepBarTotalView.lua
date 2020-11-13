local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local UI = UnityEngine.UI
local ScrollRect = UI.ScrollRect
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local SweepBarTotalView = class(unity.base)

function SweepBarTotalView:ctor()
    self.rewardContent = self.___ex.rewardContent
    self.scrollScript = self.___ex.scrollScript
    self.scroll = self.___ex.scroll
    self.canvasGroup = self.___ex.canvasGroup
    self.showTime = nil
    self.parentScrollRect = nil
    self.isDrag = false
end

function SweepBarTotalView:InitView(sweepData, showTime)
    self.showTime = showTime
    local rewardParams = {
        parentObj = self.rewardContent,
        rewardData = sweepData,
        isShowName = true,
        isReceive = true,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
    }
    RewardDataCtrl.new(rewardParams)
end
function SweepBarTotalView:start()
    if self.transform.parent then
        self.parentScrollRect = self.transform.parent:GetComponentInParent(ScrollRect)
    end
    self:ShowAnimation()
    self:RegisterRoll()
end

function SweepBarTotalView:ShowAnimation()
    if self.showTime then
        local fadeInTweener = ShortcutExtensions.DOFade(self.canvasGroup, 0, self.showTime)
        TweenSettingsExtensions.From(fadeInTweener)
    end
end

function SweepBarTotalView:RegisterRoll()
    if not self.parentScrollRect then
        return
    end

    self.scrollScript:regOnBeginDrag(function(eventData)
        if math.abs(eventData.delta.y) > math.abs(eventData.delta.x) then
            self.isDrag = true
            self.parentScrollRect:OnBeginDrag(eventData)
            self.scroll.enabled = false
        end
    end)
    self.scrollScript:regOnDrag(function(eventData)
        if self.isDrag then 
            self.parentScrollRect:OnDrag(eventData)
        end
    end)
    self.scrollScript:regOnEndDrag(function(eventData)
        if self.isDrag then
            self.isDrag = false
            self.parentScrollRect:OnEndDrag(eventData);
            self.scroll.enabled = true
        end
    end)
end

return SweepBarTotalView
