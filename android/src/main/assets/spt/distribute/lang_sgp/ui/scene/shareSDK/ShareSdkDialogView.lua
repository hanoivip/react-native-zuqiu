local UnityEngine = clr.UnityEngine
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ShareSdkDialogView = class(unity.base)

local SharePlatform = {
    FACEBOOK = "Facebook",
    LINE = "Line",
    WHATSAPP = "WhatsApp"
}

function ShareSdkDialogView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    self.finishObj = self.___ex.finishObj
    self.normalObj = self.___ex.normalObj

    self.whatsAppBtn = self.___ex.whatsAppBtn
    self.facebookBtn = self.___ex.facebookBtn
    self.lineBtn = self.___ex.lineBtn
end

function ShareSdkDialogView:InitView(title, text, imagePath)
    local isFinished = cache.getIsShareTaskComplete()
    GameObjectHelper.FastSetActive(self.finishObj, isFinished)
    GameObjectHelper.FastSetActive(self.normalObj, not isFinished)
    self.title = title
    self.text = text
    self.imagePath = imagePath
end

function ShareSdkDialogView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)

    self.whatsAppBtn:regOnButtonClick(function()
        self:ShareToTargetPlatform(SharePlatform.WHATSAPP)
    end)
    self.facebookBtn:regOnButtonClick(function()
        self:coroutine(function()
            local response = req.rewardFinish("3001")
            if api.success(response) then
                local data = response.val
                if data["3001"] ~= nil then
                    cache.setIsShareTaskComplete(data["3001"].state ~= -1)
                end
            end
        end)
        self:ShareToTargetPlatform(SharePlatform.FACEBOOK)
    end)
    self.lineBtn:regOnButtonClick(function ()
        self:ShareToTargetPlatform(SharePlatform.LINE)
    end)

    luaevt.reg("ShareSDK_CloseDialog", function()
        self:Close()
    end)
end

function ShareSdkDialogView:ShareToTargetPlatform(targetPlatform)
    luaevt.trig("SDK_SharePhotoToFacebook", self.imagePath)
end

function ShareSdkDialogView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function ShareSdkDialogView:onDestroy()
    luaevt.unreg("ShareSDK_CloseDialog")
end

return ShareSdkDialogView
