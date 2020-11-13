local GameObjectHelper = require("ui.common.GameObjectHelper")

local PeakRankMainView = class(unity.base)

function PeakRankMainView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnBack = self.___ex.btnBack
    self.realTimeRankBoard = self.___ex.realTimeRankBoard
    self.seasonRankBoard = self.___ex.seasonRankBoard
    self.rankBoardTitle = self.___ex.rankBoardTitle
end

function PeakRankMainView:start()
    self:BindButtonHandler()
end

function PeakRankMainView:InitView(peakRankModel)
    local curRankSeason = peakRankModel:GetCurRankSeason()
    if curRankSeason == nil then return end
    self.rankBoardTitle.text = curRankSeason.name
    if curRankSeason and curRankSeason.type == "current" then
        GameObjectHelper.FastSetActive(self.realTimeRankBoard.gameObject, true)
        GameObjectHelper.FastSetActive(self.seasonRankBoard.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.realTimeRankBoard.gameObject, false)
        GameObjectHelper.FastSetActive(self.seasonRankBoard.gameObject, true)
    end
end

function PeakRankMainView:BindButtonHandler()
    self.btnBack:regOnButtonClick(function()
        if self.onBack then
            self.onBack()
        end
    end)
end

function PeakRankMainView:GetRealTimeRankBoard()
    return self.realTimeRankBoard
end

function PeakRankMainView:GetSeasonRankBoard()
    return self.seasonRankBoard
end

return PeakRankMainView