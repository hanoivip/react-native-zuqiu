local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local PeakSeasonRankBoardView = class(unity.base)

function PeakSeasonRankBoardView:ctor()
    self.scrollView = self.___ex.scrollView
    self.nameTxt = self.___ex.name
    self.rank = self.___ex.rank
    self.score = self.___ex.score
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function PeakSeasonRankBoardView:start()
end

function PeakSeasonRankBoardView:InitView(peakRankModel)
    self.peakRankModel = peakRankModel
    local myRankInfo = peakRankModel:GetMyRankInfo()
    if myRankInfo then
        self.nameTxt.text = myRankInfo.name
        self.score.text = tostring(myRankInfo.peakCount)
        if myRankInfo.rank and myRankInfo.rank > 0 then
            self.rank.text = tostring(myRankInfo.rank)
        else
            self.rank.text = lang.trans("peak_no_rank")
        end
    else
        self.nameTxt.text = self.playerInfoModel:GetName()
        self.rank.text = lang.trans("peak_no_rank")
        self.score.text = lang.trans("peak_no_rank")
    end
end

return PeakSeasonRankBoardView