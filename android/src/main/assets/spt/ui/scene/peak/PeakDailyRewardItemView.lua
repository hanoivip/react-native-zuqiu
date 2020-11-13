local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PeakDailyRewardItemView = class(unity.base)

function PeakDailyRewardItemView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.ppTxt = self.___ex.ppTxt
    self.timeTxt = self.___ex.timeTxt
    self.pointTxt = self.___ex.pointTxt
    self.everyScore = self.___ex.everyScore
end

function PeakDailyRewardItemView:InitView(data)
    if data.exchangeTimes then
        self.timeTxt.text = tostring(data.exchangeTimes)
        self.ppTxt.text = "x" .. data.peakPoint
        self.normalRank.text =  tostring(data.peakCountReward)
        GameObjectHelper.FastSetActive(self.everyScore.gameObject, false)
    elseif data.peakNightCount then
        self.timeTxt.text = tostring(data.peakCount)
        self.everyScore.text = data.peakDailyCount .. "/" .. lang.transstr("hour")
        self.normalRank.text =  data.low .. (data.low == data.high and "" or (data.low > data.high and " - ..." or " - " .. data.high))
        GameObjectHelper.FastSetActive(self.ppTxt.gameObject, false)
    end
end

return PeakDailyRewardItemView