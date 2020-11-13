local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local LadderRewardDetailView = class(unity.base)

function LadderRewardDetailView:ctor()
    self.btnClose = self.___ex.btnClose
    self.txtMyRank = self.___ex.txtMyRank
    self.scrollView = self.___ex.scrollView
    self.canvasGroup = self.___ex.canvasGroup
    self.myRankView = self.___ex.myRankView
end

function LadderRewardDetailView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function LadderRewardDetailView:InitView(ladderModel)
    self.ladderModel = ladderModel
    local mySeasonRankInfo = self.ladderModel:GetMySeasonRankInfo()
    if mySeasonRankInfo then
        self.txtMyRank.text = tostring(mySeasonRankInfo.rank)
    else
        self.txtMyRank.text = ""
    end
    local mySeasonRewardData = self.ladderModel:GetMySeasonRewardData()

    self.myRankView:InitView(mySeasonRewardData)
end

function LadderRewardDetailView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function LadderRewardDetailView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function LadderRewardDetailView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function LadderRewardDetailView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function LadderRewardDetailView:Close()
    self:PlayOutAnimator()
end

return LadderRewardDetailView