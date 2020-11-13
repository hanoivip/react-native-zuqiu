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

local SweepBarView = class(unity.base)

function SweepBarView:ctor()
    self.title = self.___ex.title
    self.rewardContent = self.___ex.rewardContent
    self.scrollScript = self.___ex.scrollScript
    self.scroll = self.___ex.scroll
    self.canvasGroup = self.___ex.canvasGroup
    self.showTime = nil
    self.parentScrollRect = nil
    self.isDrag = false
end

function SweepBarView:InitView(index, sweepData, showTime)
    self.showTime = showTime
    if index then
        local titleText = "sweep_title" .. tostring(index)
        self.title.text = lang.trans(titleText)
    else
        self.title.text = ""
    end
    local rewardParams = {
        parentObj = self.rewardContent,
        rewardData = sweepData,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
    }
    RewardDataCtrl.new(rewardParams)
end

function SweepBarView:start()
    if self.transform.parent then
        self.parentScrollRect = self.transform.parent:GetComponentInParent(ScrollRect)
    end
    self:ShowAnimation()
    self:RegisterRoll()
end

function SweepBarView:ShowAnimation()
    if self.showTime then
        local fadeInTweener = ShortcutExtensions.DOFade(self.canvasGroup, 0, self.showTime)
        TweenSettingsExtensions.From(fadeInTweener)
    end
end

function SweepBarView:RegisterRoll()
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

return SweepBarView
