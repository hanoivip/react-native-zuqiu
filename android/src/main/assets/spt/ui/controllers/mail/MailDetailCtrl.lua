local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local MailDetailCtrl = class()

function MailDetailCtrl:ctor()
    local mailDetailDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Mail/MailDetail.prefab", "camera", false, true)
    self.mailDetailView = dialogcomp.contentcomp

    self.mailDetailView.clickCollect = function() self:OnBtnCollect() end
end

function MailDetailCtrl:InitView(mailDetailModel)
    self.mailDetailModel = mailDetailModel
    self.mailDetailView:InitView(mailDetailModel)
end

function MailDetailCtrl:OnBtnCollect()
    clr.coroutine(function()
        local respone = req.mailCollect(self.mailDetailModel:GetType(), self.mailDetailModel:GetMailID())
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                EventSystem.SendEvent("MailDetailModel_CheckAllRecieveButtonState", self.mailDetailModel)
                self.mailDetailModel:SetMailCollect(data)
                local popCongratulationsPage = function()
                    local isTextMail = self.mailDetailModel:IsTextMail()
                    if not isTextMail then 
                        CongratulationsPageCtrl.new(data.contents, self.mailDetailModel:IsJumpToiOSStore())
                    end
                end

                local code = self.mailDetailModel:HasHoolaiCode()
                if code then
                    self:AutoSaveTransferCodeToPhotoAlbum(code)
                end

                self.mailDetailView:Close(popCongratulationsPage)
            end
        end
    end)
end

function MailDetailCtrl:AutoSaveTransferCodeToPhotoAlbum(code)
    obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/ShareSDK/SaveTransferCodeScreenshot.prefab")
    if spt then
        spt:CreateScreenShot(code, function ()
            DialogManager.ShowToastByLang("save_transfer_code_success")
            -- 这里是ios接口，不调用保存不到相册中
            luaevt.trig("SDK_SaveImageToPhotoAlbum", spt.imgPath)
            spt:DestroyScreenshotCamera()
        end)
    end
end

return MailDetailCtrl
