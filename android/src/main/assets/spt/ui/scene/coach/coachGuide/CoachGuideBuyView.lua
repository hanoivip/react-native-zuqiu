local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AssetFinder = require("ui.common.AssetFinder")

local CoachGuideBuyView = class(unity.base)

function CoachGuideBuyView:ctor()
    self.confirmBtn = self.___ex.confirmBtn
    self.cancleBtn = self.___ex.cancleBtn
    self.cost = self.___ex.cost
    self.count = self.___ex.count
end

function CoachGuideBuyView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.confirmBtn:regOnButtonClick(function() self:OnConfirmClick() end)
    self.cancleBtn:regOnButtonClick(function() self:OnCancleClick() end)
end

function CoachGuideBuyView:InitView(guideItemData)
    self.guideItemData = guideItemData

    local dCount = guideItemData.dCount
    local mCount = guideItemData.mCount
    local weekCount = guideItemData.weekCount
    local monthCount = guideItemData.monthCount
    local diamondState = guideItemData.dCount > 0
    local mState = guideItemData.mCount > 0

    GameObjectHelper.FastSetActive(self.cost.d, diamondState)
    GameObjectHelper.FastSetActive(self.cost.m, mState)

    self.count.d.text = "x" .. string.formatNumWithUnit(dCount)
    self.count.m.text = "x" .. string.formatNumWithUnit(mCount)
    self.count.week.text = "x" .. weekCount
    self.count.month.text = "x" .. monthCount
end

function CoachGuideBuyView:Close(callback)
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
        if type(callback) == "function" then
            callback()
        end
    end)
end

function CoachGuideBuyView:OnConfirmClick()
    if self.onConfirmClick then
        self.onConfirmClick()
    end
end

function CoachGuideBuyView:OnCancleClick()
    self:Close()
end

return CoachGuideBuyView
