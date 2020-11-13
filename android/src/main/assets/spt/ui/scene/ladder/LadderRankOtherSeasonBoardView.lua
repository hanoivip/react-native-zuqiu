local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LadderRankOtherSeasonBoardView = class(unity.base)

function LadderRankOtherSeasonBoardView:ctor()
    self.scrollView = self.___ex.scrollView
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.rank = self.___ex.rank
    self.honorPoint = self.___ex.honorPoint
    self.honorPointArea = self.___ex.honorPointArea
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function LadderRankOtherSeasonBoardView:start()
end

function LadderRankOtherSeasonBoardView:InitView(ladderModel)
    local isRealTimeRank = false
    local seasonList = ladderModel:GetRankSeasonList()
    for i, seasonData in ipairs(seasonList) do
        if seasonData.isSelect and seasonData.type == "current" then
            isRealTimeRank = true
            break
        end
    end
    if isRealTimeRank then
        GameObjectHelper.FastSetActive(self.honorPointArea, false)
        local myRealTimeRankInfo = ladderModel:GetMyRealTimeRankInfo()
        self.nameTxt.text = myRealTimeRankInfo.name
        self.level.text = "Lv " .. tostring(myRealTimeRankInfo.level)
        self.rank.text = tostring(myRealTimeRankInfo.rank)
    else
        GameObjectHelper.FastSetActive(self.honorPointArea, true)
        local mySeasonRankInfo = ladderModel:GetMySeasonRankInfo()
        if mySeasonRankInfo then
            self.nameTxt.text = mySeasonRankInfo.name
            self.level.text = "Lv " .. tostring(mySeasonRankInfo.level)
            self.rank.text = tostring(mySeasonRankInfo.rank)
            self.honorPoint.text = tostring(mySeasonRankInfo.honorPoint)
        else
            self.nameTxt.text = self.playerInfoModel:GetName()
            self.level.text = "Lv " .. tostring(self.playerInfoModel:GetLevel())
            self.rank.text = lang.trans("train_no_rank")
            self.honorPoint.text = "0"
        end
    end
end

return LadderRankOtherSeasonBoardView