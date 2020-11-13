local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CommonConstants = require("ui.common.CommonConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local GoodGuideView = class(unity.base)

function GoodGuideView:ctor()
    self.confirmBtn = self.___ex.confirmBtn
    self.cancleBtn = self.___ex.cancleBtn
    self.closeBtn = self.___ex.closeBtn
    self.leftStoreGO = self.___ex.leftStoreGO
    self.leftEmailGO = self.___ex.leftEmailGO
    self.rightStoreGO = self.___ex.rightStoreGO
    self.rightEmailGO = self.___ex.rightEmailGO

    DialogAnimation.Appear(self.transform, nil)

    self.confirmBtn:regOnButtonClick(function ()
        -- 跳转到苹果商店
        UnityEngine.Application.OpenURL(CommonConstants.StoreAddress)
        self:Close()
    end)

    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    self.cancleBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function GoodGuideView:InitView(isStore)
    GameObjectHelper.FastSetActive(self.leftStoreGO, isStore)
    GameObjectHelper.FastSetActive(self.rightStoreGO, isStore)
    GameObjectHelper.FastSetActive(self.leftEmailGO, not isStore)
    GameObjectHelper.FastSetActive(self.rightEmailGO, not isStore)
end

function GoodGuideView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return GoodGuideView