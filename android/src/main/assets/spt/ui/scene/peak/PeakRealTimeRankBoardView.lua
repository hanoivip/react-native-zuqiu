local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local PeakRealTimeRankBoardView = class(unity.base)

function PeakRealTimeRankBoardView:ctor()
    self.scrollView = self.___ex.scrollView
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.rank = self.___ex.rank
    self.prePeakDailyCount = self.___ex.prePeakDailyCount
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function PeakRealTimeRankBoardView:start()
end

function PeakRealTimeRankBoardView:InitView(peakRankModel)
    self.peakRankModel = peakRankModel
    local myRankInfo = peakRankModel:GetMyRealTimeRankInfo()
    if myRankInfo then
        self.nameTxt.text = myRankInfo.name
        self.level.text = "Lv " .. tostring(myRankInfo.level)
        if myRankInfo.rank and myRankInfo.rank > 0 then
            self.rank.text = tostring(myRankInfo.rank)
        else
            self.rank.text = lang.trans("peak_no_rank")
        end
    else
        self.nameTxt.text = self.playerInfoModel:GetName()
        self.level.text = "Lv " .. tostring(self.playerInfoModel:GetLevel())
        self.rank.text = lang.trans("peak_no_rank")
    end
    self.prePeakDailyCount.text = tostring(peakRankModel:GetPrePeakDailyCount())
end

return PeakRealTimeRankBoardView