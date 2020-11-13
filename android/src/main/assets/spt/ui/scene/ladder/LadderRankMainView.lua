local GameObjectHelper = require("ui.common.GameObjectHelper")

local LadderRankMainView = class(unity.base)

function LadderRankMainView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnBack = self.___ex.btnBack
    self.currentSeasonRankBoard = self.___ex.currentSeasonRankBoard
    self.otherSeasonRankBoard = self.___ex.otherSeasonRankBoard
    self.txtRankBoardTitle = self.___ex.txtRankBoardTitle
end

function LadderRankMainView:start()
    self:BindButtonHandler()
end

function LadderRankMainView:InitView(ladderModel)
    local curRankSeason = ladderModel:GetCurRankSeason()
    self.txtRankBoardTitle.text = curRankSeason.name
    if curRankSeason and curRankSeason.type == "season" then
        GameObjectHelper.FastSetActive(self.currentSeasonRankBoard.gameObject, true)
        GameObjectHelper.FastSetActive(self.otherSeasonRankBoard.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.currentSeasonRankBoard.gameObject, false)
        GameObjectHelper.FastSetActive(self.otherSeasonRankBoard.gameObject, true)
    end
end

function LadderRankMainView:BindButtonHandler()
    self.btnBack:regOnButtonClick(function()
        if self.onBack then
            self.onBack()
        end
    end)
end

function LadderRankMainView:GetCurrentSeasonRankBoard()
    return self.currentSeasonRankBoard
end

function LadderRankMainView:GetOtherSeasonRankBoard()
    return self.otherSeasonRankBoard
end

return LadderRankMainView