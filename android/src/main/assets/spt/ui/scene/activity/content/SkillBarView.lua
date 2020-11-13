local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local SkillBarView = class(unity.base)

function SkillBarView:ctor()
    self.parentRect = self.___ex.parentRect
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnDiable = self.___ex.rewardBtnDiable
    self.finishIcon = self.___ex.finishIcon
    self.desc = self.___ex.desc
    self.dragEvent = self.___ex.dragEvent
    self.rewardScrollRect = self.___ex.rewardScrollRect
    self.isHorizontal = true
end

function SkillBarView:start()
     self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)

    self.dragEvent:regOnBeginDrag(function(eventData)
        self:OnBeginDrag(eventData)
    end)

    self.dragEvent:regOnDrag(function(eventData)
        self:OnDrag(eventData)
    end)

    self.dragEvent:regOnEndDrag(function(eventData)
        self:OnEndDrag(eventData)
    end)
end

-- state = 0 时表示可以领取奖励
function SkillBarView:InitRewardState(state, beCompleteValue, condition)
    local beFinished, beRecieved = false, false
    if state == 1 then
        beFinished = true
        beRecieved = true
    elseif state == 0 then
        beFinished = true
    end
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, beFinished and not beRecieved)
    GameObjectHelper.FastSetActive(self.rewardBtnDiable, not beRecieved and not beFinished)
    GameObjectHelper.FastSetActive(self.finishIcon, beFinished and beRecieved)
    local isCompleted = tobool(beCompleteValue >= condition)
    local completeValueStr = isCompleted and "<color=#9CDC14>" .. beCompleteValue .. "</color>" or "<color=red>" .. beCompleteValue .. "</color>"
    self.desc.text = lang.transstr("skill_levelup_target_number", completeValueStr, condition)
end

function SkillBarView:OnRewardBtnClick()
    if self.onRewardBtnClick then
        self.onRewardBtnClick(self.barData.subID)
    end
end

function SkillBarView:InitView(barData, cScroll, scrollRect)
    self.barData = barData
    self.cScroll = cScroll
    self.scrollRect = scrollRect
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = barData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }

    RewardDataCtrl.new(rewardParams)

    self:InitRewardState(barData.status, barData.value, barData.condition)
end

function SkillBarView:OnBeginDrag(eventData)
    local vector1 = self.isHorizontal and eventData.delta.y or eventData.delta.x
    local vector2 = self.isHorizontal and eventData.delta.x or eventData.delta.y
    if math.abs(vector1) > math.abs(vector2) then
        self.isDrag = true
        self.cScroll:OnBeginDrag(eventData)
        self.scrollRect:OnBeginDrag(eventData)
        self.rewardScrollRect.enabled = false
    end
end

function SkillBarView:OnDrag(eventData)
    if self.isDrag then
        self.cScroll:OnDrag(eventData)
        self.scrollRect:OnDrag(eventData)
    end
end

function SkillBarView:OnEndDrag(eventData)
    if self.isDrag then
        self.cScroll:OnEndDrag(eventData)
        self.scrollRect:OnEndDrag(eventData)
        self.rewardScrollRect.enabled = true
        self.isDrag = false
    end
end

return SkillBarView
