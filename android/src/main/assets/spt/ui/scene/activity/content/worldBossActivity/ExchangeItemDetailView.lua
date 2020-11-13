local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ExchangeItemDetailView = class(unity.base)

function ExchangeItemDetailView:ctor()
    self.exchangeItemSpt = self.___ex.exchangeItemSpt
    self.nameTxt = self.___ex.name
    self.ownNum = self.___ex.ownNum
    self.content = self.___ex.content
    self.btnClose = self.___ex.btnClose
    self.title = self.___ex.title
    self.canvasGroup = self.___ex.canvasGroup
    self.srcContent = self.___ex.srcContent
end

function ExchangeItemDetailView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function ExchangeItemDetailView:InitView(exchangeItemModel)
    self.title.text = lang.trans("exchange_item_title")
    self.nameTxt.text = exchangeItemModel:GetName()
    self.content.text = exchangeItemModel:GetDesc()
    self.srcContent.text = exchangeItemModel:GetAccess()
    self.exchangeItemSpt:InitView(exchangeItemModel)
end

function ExchangeItemDetailView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function ExchangeItemDetailView:EnterScene()
end

function ExchangeItemDetailView:ExitScene()
end

return ExchangeItemDetailView