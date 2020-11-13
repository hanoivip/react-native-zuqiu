local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local DayItemView = class()

function DayItemView:ctor()
    self.content = self.___ex.content
    self.done = self.___ex.done
    self.day = self.___ex.day
    self.dayIndex = nil
end

function DayItemView:start()

end

function DayItemView:HasSign(lastDay)
    local isSign = false
    if self.dayIndex <= lastDay then
        isSign = true
    end
    GameObjectHelper.FastSetActive(self.done.gameObject, isSign)
    GameObjectHelper.FastSetActive(self.day.gameObject, not isSign)
end

function DayItemView:InitView(data, lastDay, isSigned)
    self.dayIndex = data.day
    self.day.text = tostring(self.dayIndex)
    local color
    if not isSigned and self.dayIndex == lastDay + 1 then
        color = ColorConversionHelper.ConversionColor(244, 239, 128)
    else
        color = ColorConversionHelper.ConversionColor(227, 226, 231)
    end
    self.day.color = color
    self:HasSign(lastDay)
    local rewardParams = {
        parentObj = self.content,
        rewardData = data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

return DayItemView