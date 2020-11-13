local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local HistoryDataBoardView = class(unity.base)

function HistoryDataBoardView:ctor()
    self.contentTxt = self.___ex.contentTxt
    self.closeBtn = self.___ex.closeBtn
    self.titleTxt = self.___ex.titleTxt

    DialogAnimation.Appear(self.transform)
end

function HistoryDataBoardView:Init(txt, title)
    self.contentTxt.text = txt
    if title then
        self.titleTxt.text = title
    end
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function HistoryDataBoardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return HistoryDataBoardView