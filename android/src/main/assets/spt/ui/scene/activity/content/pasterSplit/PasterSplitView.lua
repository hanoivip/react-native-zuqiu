local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterSplitView = class(ActivityParentView)

PasterSplitView.splitType = {
    Money = "m",
    Diamond = "d",
    BlackDiamond = "bkd",
}

function PasterSplitView:ctor()
    self.residualTime = self.___ex.residualTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.plusSymbol = self.___ex.plusSymbol
    self.pasterContainer = self.___ex.pasterContainer
    self.beforeSelect = self.___ex.beforeSelect
    self.afterSelect = self.___ex.afterSelect
    self.btnMoney = self.___ex.btnMoney
    self.btnDiamond = self.___ex.btnDiamond
    self.btnCoin = self.___ex.btnCoin
    self.monthPiece = self.___ex.monthPiece
    self.weekPiece = self.___ex.weekPiece
    self.paterPieceView = self.___ex.paterPieceView
    self.timeAdmtText = self.___ex.timeAdmtText
    self.pasterNameText = self.___ex.pasterNameText
    self.pasterPieceNameText = self.___ex.pasterPieceNameText
    self.btnTipmText = self.___ex.btnTipmText
    self.mBtnText = self.___ex.mBtnText
    self.btnTipdText = self.___ex.btnTipdText
    self.dBtnText = self.___ex.dBtnText
    self.btnTipbkdText = self.___ex.btnTipbkdText
    self.bkdBtnText = self.___ex.bkdBtnText

    self.residualTimer = nil
end

function PasterSplitView:start()
    self.plusSymbol:regOnButtonClick(function()
        self:OnPlusSymbolClick()
    end)

    self.btnMoney:regOnButtonClick(function()
        self:OnBtnSplitClick(self.splitType.Money)
    end)

    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnSplitClick(self.splitType.Diamond)
    end)

    self.btnCoin:regOnButtonClick(function()
        self:OnBtnSplitClick(self.splitType.BlackDiamond)
    end)
end

function PasterSplitView:InitView(pasterSplitModel)
    self.pasterSplitModel = pasterSplitModel
    self:SetTimeAdmtText()
end

function PasterSplitView:SetTimeAdmtText()
    local residualTime = tostring(self.pasterSplitModel:GetResidualTime())
    local totalTime = tostring(self.pasterSplitModel:GetTotalTimePerDay())
    self.timeAdmtText.text = lang.transstr("pasterSplit_activity_splitNumPerDay", residualTime, totalTime)
end

function PasterSplitView:OnPlusSymbolClick()
    if self.clickPlusSymbol then
        self.clickPlusSymbol()
    end
end

function PasterSplitView:OnBtnSplitClick(tag)
    if self.clickBtnSplit then
        self.clickBtnSplit(tag)
    end
end

return PasterSplitView