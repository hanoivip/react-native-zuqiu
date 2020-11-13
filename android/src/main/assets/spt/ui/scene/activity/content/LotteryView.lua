local Timer = require("ui.common.Timer")
local ReqEventModel = require("ui.models.event.ReqEventModel")

local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local LotteryView = class(ActivityParentView)

function LotteryView:ctor()
    self.timeTxt = self.___ex.timeTxt
    self.scrollView = self.___ex.scrollView
    self.checkGroup = self.___ex.checkGroup
    self.lobbyBoard = self.___ex.lobbyBoard
    self.historyBoard = self.___ex.historyBoard
    self.countValue = self.___ex.countValue
    self.winRateValue = self.___ex.winRateValue
    self.totalPrizeValue = self.___ex.totalPrizeValue
    self.historyScrollView = self.___ex.historyScrollView
    self.historyRedPoint = self.___ex.historyRedPoint
end

function LotteryView:InitView(lotteryModel)
    self.lotteryModel = lotteryModel

    self.scrollView:InitView(self.lotteryModel.list)


    local timeToFinish = self.lotteryModel.endTime - self.lotteryModel.serverTime
    local timeTable = string.convertSecondToTimeTable(timeToFinish)

    self.timeTxt.text = lang.trans("activity_nationalWelfare_remainTime", timeTable.day, timeTable.hour, timeTable.minute)

    self:UpdateHistoryRedPoint()
end

function LotteryView:OnEnterScene()
    EventSystem.AddEvent("LotteryModel:RefreshData", self, self.OnRefreshData)
    EventSystem.AddEvent("LotteryModel:UpdateModel", self, self.OnUpdateModel)
    EventSystem.AddEvent("LotteryModel:UpdateHistory", self, self.OnUpdateHistory)
    EventSystem.AddEvent("LotteryModel:UpdateHistoryStatistic", self, self.OnUpdateHistoryStatistic)
    EventSystem.AddEvent("LotteryModel:ReqEventModel_lotteryStake", self, self.UpdateHistoryRedPoint)
end

function LotteryView:OnExitScene()
    EventSystem.RemoveEvent("LotteryModel:RefreshData", self, self.OnRefreshData)
    EventSystem.RemoveEvent("LotteryModel:UpdateModel", self, self.OnUpdateModel)
    EventSystem.RemoveEvent("LotteryModel:UpdateHistory", self, self.OnUpdateHistory)
    EventSystem.RemoveEvent("LotteryModel:UpdateHistoryStatistic", self, self.OnUpdateHistoryStatistic)
    EventSystem.RemoveEvent("LotteryModel:ReqEventModel_lotteryStake", self, self.UpdateHistoryRedPoint)
end

function LotteryView:OnRefresh()

end
function LotteryView:InitHistoryView(historyModel, updateScrollView)
    self.countValue.text = tostring(historyModel.statistic.stakeTotalTimes)
    local winRate = (historyModel.statistic.stakeOverTimes and historyModel.statistic.stakeOverTimes ~= 0) and (historyModel.statistic.stakeWinTimes / historyModel.statistic.stakeOverTimes * 100) or 0
    self.winRateValue.text = string.format(lang.transstr("lottery_history_percentage"), winRate)
    self.totalPrizeValue.text = self:FormatAmount(historyModel.statistic.prized)

    if updateScrollView then
        self.historyScrollView:InitView(historyModel.list)
    end
end

function LotteryView:OnUpdateModel(index, item)
    self.scrollView:UpdateItem(index, item)
end

function LotteryView:OnUpdateHistory(index, item)
    self.historyScrollView:UpdateItem(index, item)
end

function LotteryView:OnUpdateHistoryStatistic(historyModel)
    self:InitHistoryView(historyModel, false)
end

function LotteryView:OnRefreshData(lotteryModel)
    local pos = self.scrollView:getScrollNormalizedPos()
    self:InitView(lotteryModel)
    self.scrollView:scrollToPosImmediate(pos)
end

function LotteryView:FormatAmount(amount)
    if amount < 1e8 then
        return string.format(lang.transstr("lottery_history_amount_e4"), amount / 1e4)
    else
        return string.format(lang.transstr("lottery_history_amount_e8"), amount / 1e8)
    end
end

function LotteryView:UpdateHistoryRedPoint()
    local isShow = false
    local lotteryStake = ReqEventModel.GetInfo("lotteryStake")
    isShow = tonumber(lotteryStake) > 0
    self.historyRedPoint:SetActive(isShow)
end
return LotteryView
