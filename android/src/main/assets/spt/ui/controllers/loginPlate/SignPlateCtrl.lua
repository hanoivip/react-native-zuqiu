local SignTipCtrl = require("ui.controllers.activity.content.SignTipCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlateBaseCtrl = require("ui.controllers.loginPlate.PlateBaseCtrl")
local EventSystem = require("EventSystem")
local SignPlateCtrl = class(PlateBaseCtrl)

-- 登录签到弹板使用活动每日签到model
function SignPlateCtrl:InitWithProtocol()
    self.view:InitView(self.plateModel)
    self.view.clickSign = function() self:ClickSign() end
    self.view.clickClose = function() self:ClickClose() end
    self.view.onEventDestroy = function()
        SignPlateCtrl.isOpenSignedPage = false
    end
end

function SignPlateCtrl:OnEnterScene()
    self.view:OnEnterScene()
    SignPlateCtrl.isOpenSignedPage = true
end

function SignPlateCtrl:OnExitScene()
    self.view:OnExitScene()
    SignPlateCtrl.isOpenSignedPage = false
end

function SignPlateCtrl:ClickClose()
    self:Close()
end

function SignPlateCtrl:ClickSign()   
    local isSigned = self.plateModel:GetSign()
    if isSigned then
        return
    end

    clr.coroutine( function()
        local response = req.activitySign()
        if api.success(response) then
            local data = response.val
            self.plateModel:SetSignCollect(data)
            self:Close()
            CongratulationsPageCtrl.new(data.contents)
        end
    end)
end

return SignPlateCtrl
