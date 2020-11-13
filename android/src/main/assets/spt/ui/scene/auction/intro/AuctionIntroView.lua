local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local AuctionIntroView = class(unity.base, "AuctionIntroView")

function AuctionIntroView:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.txtIntro = self.___ex.txtIntro
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
end

function AuctionIntroView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function AuctionIntroView:InitView(auctionIntroModel)
    self.model = auctionIntroModel
    self.txtIntro.text = self.model:GetIntro()
end

function AuctionIntroView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function AuctionIntroView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return AuctionIntroView