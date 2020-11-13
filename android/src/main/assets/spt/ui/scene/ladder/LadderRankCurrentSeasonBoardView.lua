local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local LadderRankCurrentSeasonBoardView = class(unity.base)

function LadderRankCurrentSeasonBoardView:ctor()
    self.scrollView = self.___ex.scrollView
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.rank = self.___ex.rank
    self.honorPoint = self.___ex.honorPoint
    self.seasonCd = self.___ex.seasonCd
    self.seasonTimeArea = self.___ex.seasonTimeArea
    self.seasonEndArea = self.___ex.seasonEndArea
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function LadderRankCurrentSeasonBoardView:start()
end

function LadderRankCurrentSeasonBoardView:InitView(ladderModel)
    self.ladderModel = ladderModel
    local mySeasonRankInfo = ladderModel:GetMySeasonRankInfo()
    if mySeasonRankInfo then
        self.nameTxt.text = mySeasonRankInfo.name
        self.level.text = "Lv " .. tostring(mySeasonRankInfo.level)
        self.rank.text = tostring(mySeasonRankInfo.rank)
        self.honorPoint.text = tostring(mySeasonRankInfo.honorPoint)
    else
        self.nameTxt.text = self.playerInfoModel:GetName()
        self.level.text = "Lv " .. tostring(self.playerInfoModel:GetLevel())
        self.rank.text = ""
        self.honorPoint.text = ""
    end
    if self.seasonCd and self.seasonTimeArea and self.seasonEndArea then
        self:InitSeasonCd()
    end
end

function LadderRankCurrentSeasonBoardView:InitSeasonCd()
    local seasonCd = self.ladderModel:GetCurSeasonCd()
    if seasonCd <= 0 then
        GameObjectHelper.FastSetActive(self.seasonTimeArea, false)
        GameObjectHelper.FastSetActive(self.seasonEndArea, true)
    else
        GameObjectHelper.FastSetActive(self.seasonTimeArea, true)
        GameObjectHelper.FastSetActive(self.seasonEndArea, false)
        self:coroutine(function()
            self.seasonCd.text = string.convertSecondToTime(seasonCd)
            while true do
                coroutine.yield(WaitForSeconds(1))
                seasonCd = math.max(seasonCd - 1, 0)
                if seasonCd <= 0 then
                    GameObjectHelper.FastSetActive(self.seasonTimeArea, false)
                    GameObjectHelper.FastSetActive(self.seasonEndArea, true)
                    break
                end
                self.seasonCd.text = string.convertSecondToTime(seasonCd)
            end
        end)
    end
end

return LadderRankCurrentSeasonBoardView