local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local FancyPieceDetailView = class(unity.base)

function FancyPieceDetailView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.fancyPieceSpt = self.___ex.fancyPieceSpt
    self.itemNameTxt = self.___ex.itemNameTxt
    self.ownNumTxt = self.___ex.ownNumTxt
    self.introductionTxt = self.___ex.introductionTxt
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
end

function FancyPieceDetailView:start()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FancyPieceDetailView:InitView(fancyPieceModel)
    self.titleTxt.text = lang.trans("itemDetail_title")
    local name = fancyPieceModel:GetName()
    self.itemNameTxt.text = name
    local playerInfoModel = PlayerInfoModel.new()
    local num = tonumber(playerInfoModel:GetFancyPiece())
    self.ownNumTxt.text = lang.trans("itemDetail_number", num)
    local des = fancyPieceModel:GetDesc()
    self.introductionTxt.text = des
    self.fancyPieceSpt:InitView(fancyPieceModel)
end

function FancyPieceDetailView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function FancyPieceDetailView:EnterScene()
end

function FancyPieceDetailView:ExitScene()
end

return FancyPieceDetailView
